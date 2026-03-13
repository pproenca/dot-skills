#!/usr/bin/env python3
"""Generate a browser-based review UI for an RFC markdown file.

Supports three modes:
  - Server mode (default): starts an HTTP server on localhost, auto-saves
    feedback to a workspace directory, supports iteration with previous feedback.
  - Live mode (--live): opens UI with section skeleton, agent pushes sections
    one at a time via HTTP, user reviews each section in real-time via SSE.
  - Static mode (--static): writes a standalone HTML file, feedback downloads
    as a Blob to ~/Downloads (legacy behavior).
"""

import argparse
import json
import os
import queue
import re
import signal
import subprocess
import sys
import threading
import time
import webbrowser
from functools import partial
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
from urllib.parse import urlparse, parse_qs


def kill_port(port: int) -> None:
    """Kill any process listening on the given port (macOS + Linux)."""
    killed = False
    # Try lsof (macOS, some Linux)
    try:
        result = subprocess.run(
            ["lsof", "-ti", f":{port}"],
            capture_output=True, text=True, timeout=5,
        )
        for pid_str in result.stdout.strip().split("\n"):
            if pid_str.strip():
                try:
                    os.kill(int(pid_str.strip()), signal.SIGTERM)
                    killed = True
                except (ProcessLookupError, ValueError):
                    pass
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass

    if killed:
        time.sleep(0.5)
        return

    # Fallback: fuser (Linux)
    try:
        subprocess.run(
            ["fuser", "-k", f"{port}/tcp"],
            capture_output=True, timeout=5,
        )
        time.sleep(0.5)
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass


def slugify(heading: str) -> str:
    """Convert a heading to a URL-friendly section ID."""
    s = heading.lower().strip()
    s = re.sub(r'[^a-z0-9\s-]', '', s)
    s = re.sub(r'[\s]+', '-', s)
    s = re.sub(r'-+', '-', s)
    return s.strip('-')


class LiveSession:
    """Thread-safe state manager for live authoring mode.

    Holds section state, threading.Event per section for blocking waits,
    and queue.Queue per SSE client for fan-out broadcasting.
    """

    def __init__(self, title: str, sections_plan: list[str],
                 workspace: Path | None = None):
        self.lock = threading.Lock()
        self.title = title
        self.sections_plan = sections_plan
        self.sections: dict[str, dict] = {}
        self.current_section: str | None = None
        self.overall_status = "in_progress"
        self.workspace = workspace
        self._events: dict[str, threading.Event] = {}
        self._feedback: dict[str, dict] = {}
        self._sse_clients: list[queue.Queue] = []

        for i, heading in enumerate(sections_plan):
            sid = slugify(heading)
            self.sections[sid] = {
                "heading": heading,
                "order": i + 1,
                "markdown": "",
                "status": "pending",
                "feedback": None,
                "history": [],
            }
            self._events[sid] = threading.Event()

    def add_section(self, section_id: str, heading: str, markdown: str) -> None:
        with self.lock:
            if section_id in self.sections:
                self.sections[section_id]["markdown"] = markdown
                self.sections[section_id]["status"] = "review"
                self.sections[section_id]["heading"] = heading
            else:
                self.sections[section_id] = {
                    "heading": heading,
                    "order": len(self.sections) + 1,
                    "markdown": markdown,
                    "status": "review",
                    "feedback": None,
                    "history": [],
                }
                self._events[section_id] = threading.Event()
            self.current_section = section_id
            self._broadcast("section-added", {
                "id": section_id,
                "heading": heading,
                "markdown": markdown,
                "status": "review",
                "order": self.sections[section_id]["order"],
            })
            self._save_state()

    def update_section(self, section_id: str, markdown: str) -> bool:
        with self.lock:
            if section_id not in self.sections:
                return False
            sec = self.sections[section_id]
            if sec["markdown"]:
                sec["history"].append({
                    "markdown": sec["markdown"],
                    "feedback": sec["feedback"],
                })
            sec["markdown"] = markdown
            sec["status"] = "review"
            sec["feedback"] = None
            # Reset event for new feedback wait
            self._events[section_id] = threading.Event()
            self._broadcast("section-updated", {
                "id": section_id,
                "heading": sec["heading"],
                "markdown": markdown,
                "status": "review",
            })
            self._save_state()
            return True

    def set_feedback(self, section_id: str, action: str,
                     text: str = "", inline_comments: list | None = None) -> bool:
        with self.lock:
            if section_id not in self.sections:
                return False
            sec = self.sections[section_id]
            feedback = {
                "action": action,
                "text": text,
                "inline_comments": inline_comments or [],
            }
            sec["feedback"] = feedback
            sec["status"] = "approved" if action == "approve" else "changes_requested"
            self._feedback[section_id] = feedback
            self._broadcast("section-status", {
                "id": section_id,
                "status": sec["status"],
                "feedback": feedback,
            })
            self._save_state()
        # Signal outside the lock so waiters can acquire it
        self._events[section_id].set()
        return True

    def wait_for_feedback(self, section_id: str, timeout: float = 300) -> dict:
        event = self._events.get(section_id)
        if not event:
            return {"error": "unknown section"}
        triggered = event.wait(timeout=timeout)
        if not triggered:
            return {"timeout": True}
        with self.lock:
            return dict(self._feedback.get(section_id, {"timeout": True}))

    def get_state(self) -> dict:
        with self.lock:
            return {
                "mode": "live",
                "title": self.title,
                "sections_plan": list(self.sections_plan),
                "sections": {k: dict(v) for k, v in self.sections.items()},
                "current_section": self.current_section,
                "overall_status": self.overall_status,
            }

    def register_sse_client(self) -> queue.Queue:
        q: queue.Queue = queue.Queue(maxsize=200)
        with self.lock:
            self._sse_clients.append(q)
        return q

    def unregister_sse_client(self, q: queue.Queue) -> None:
        with self.lock:
            if q in self._sse_clients:
                self._sse_clients.remove(q)

    def _broadcast(self, event_type: str, data: dict) -> None:
        """Send event to all SSE clients. Must be called with lock held."""
        for q in self._sse_clients[:]:
            try:
                q.put_nowait({"type": event_type, "data": data})
            except queue.Full:
                pass

    def _save_state(self) -> None:
        """Persist session state to workspace/session.json. Lock must be held."""
        if not self.workspace:
            return
        try:
            state = {
                "mode": "live",
                "title": self.title,
                "sections_plan": self.sections_plan,
                "sections": self.sections,
                "current_section": self.current_section,
                "overall_status": self.overall_status,
            }
            path = self.workspace / "session.json"
            path.write_text(json.dumps(state, indent=2) + "\n", encoding="utf-8")
        except OSError:
            pass


def build_html(md_path: Path | None, title: str, previous_feedback: dict | None,
               iteration: int, server_mode: bool, live_mode: bool = False) -> str:
    """Read the markdown file + template and produce the final HTML."""
    md_content = ""
    if md_path and md_path.exists():
        md_content = md_path.read_text(encoding="utf-8")

    template_path = Path(__file__).resolve().parent.parent / "assets" / "review_template.html"
    template = template_path.read_text(encoding="utf-8")

    html = template.replace("__MARKDOWN_CONTENT__", json.dumps(md_content))
    html = html.replace("__DOC_TITLE__", title.replace('"', "&quot;"))
    html = html.replace("__PREVIOUS_FEEDBACK__", json.dumps(previous_feedback or {}))
    html = html.replace("__ITERATION__", str(iteration))
    html = html.replace("__SERVER_MODE__", "true" if server_mode else "false")
    html = html.replace("__LIVE_MODE__", "true" if live_mode else "false")

    return html


class ReviewHandler(BaseHTTPRequestHandler):
    """Serves the review HTML and handles feedback saves.

    Regenerates the HTML on each GET / so that refreshing the browser
    picks up doc changes without restarting the server.
    """

    def __init__(self, md_path: Path | None, title: str,
                 feedback_path: Path | None,
                 previous_feedback: dict | None, iteration: int,
                 live_session: LiveSession | None,
                 *args, **kwargs):
        self.md_path = md_path
        self.title = title
        self.feedback_path = feedback_path
        self.previous_feedback = previous_feedback
        self.iteration = iteration
        self.live_session = live_session
        super().__init__(*args, **kwargs)

    def _no_cache_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.send_header("Pragma", "no-cache")
        self.send_header("Expires", "0")

    def _json_response(self, code: int, data: dict) -> None:
        body = json.dumps(data).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self._no_cache_headers()
        self.end_headers()
        self.wfile.write(body)

    def _read_body(self) -> bytes:
        length = int(self.headers.get("Content-Length", 0))
        return self.rfile.read(length)

    # ---- GET ----

    def do_GET(self) -> None:
        if self.path == "/" or self.path == "/index.html":
            live_mode = self.live_session is not None
            html = build_html(self.md_path, self.title,
                              self.previous_feedback, self.iteration,
                              server_mode=True, live_mode=live_mode)
            content = html.encode("utf-8")
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self._no_cache_headers()
            self.end_headers()
            self.wfile.write(content)

        elif self.path == "/api/feedback":
            data = b"{}"
            if self.feedback_path and self.feedback_path.exists():
                data = self.feedback_path.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(data)))
            self._no_cache_headers()
            self.end_headers()
            self.wfile.write(data)

        elif self.path == "/api/session" and self.live_session:
            self._json_response(200, self.live_session.get_state())

        elif self.path.startswith("/api/wait-feedback") and self.live_session:
            parsed = urlparse(self.path)
            params = parse_qs(parsed.query)
            section_id = params.get("section", [None])[0]
            if not section_id:
                self._json_response(400, {"error": "missing section parameter"})
                return
            # This blocks the thread until user acts or timeout (5 min)
            result = self.live_session.wait_for_feedback(section_id)
            self._json_response(200, result)

        elif self.path == "/events" and self.live_session:
            self._handle_sse()

        elif self.path.startswith("/assets/"):
            self._serve_asset()

        else:
            self.send_error(404)

    def _serve_asset(self) -> None:
        """Serve bundled JS/CSS assets from the assets/ directory."""
        filename = self.path.split("/assets/", 1)[-1]
        # Only allow safe filenames (no path traversal)
        if "/" in filename or "\\" in filename or ".." in filename:
            self.send_error(403)
            return
        assets_dir = Path(__file__).resolve().parent.parent / "assets"
        asset_path = assets_dir / filename
        if not asset_path.exists() or not asset_path.is_file():
            self.send_error(404)
            return
        content_types = {
            ".js": "application/javascript",
            ".css": "text/css",
            ".html": "text/html",
        }
        ct = content_types.get(asset_path.suffix, "application/octet-stream")
        data = asset_path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", ct)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Cache-Control", "public, max-age=86400")
        self.end_headers()
        self.wfile.write(data)

    def _handle_sse(self) -> None:
        """Server-Sent Events stream for live mode."""
        self.send_response(200)
        self.send_header("Content-Type", "text/event-stream")
        self.send_header("Cache-Control", "no-cache")
        self.send_header("Connection", "keep-alive")
        self.end_headers()

        client_queue = self.live_session.register_sse_client()
        try:
            # Send current state as initial catch-up events
            state = self.live_session.get_state()
            for section_id, sec in state["sections"].items():
                if sec["status"] != "pending":
                    self._send_sse("section-added", {
                        "id": section_id,
                        "heading": sec["heading"],
                        "markdown": sec["markdown"],
                        "status": sec["status"],
                        "order": sec["order"],
                    })

            # Stream new events as they arrive
            while True:
                try:
                    event = client_queue.get(timeout=15)
                    self._send_sse(event["type"], event["data"])
                except queue.Empty:
                    # Keep-alive ping
                    self._send_sse("ping", {})
        except (BrokenPipeError, ConnectionResetError, OSError):
            pass
        finally:
            self.live_session.unregister_sse_client(client_queue)

    def _send_sse(self, event_type: str, data: dict) -> None:
        msg = f"event: {event_type}\ndata: {json.dumps(data)}\n\n"
        self.wfile.write(msg.encode("utf-8"))
        self.wfile.flush()

    # ---- POST ----

    def do_POST(self) -> None:
        if self.path == "/api/feedback":
            body = self._read_body()
            try:
                data = json.loads(body)
                if not isinstance(data, dict):
                    raise ValueError("Expected JSON object")
                if self.feedback_path:
                    self.feedback_path.write_text(
                        json.dumps(data, indent=2) + "\n")
                self._json_response(200, {"ok": True})
            except (json.JSONDecodeError, OSError, ValueError) as e:
                self._json_response(500, {"error": str(e)})

        elif self.path == "/api/section/add" and self.live_session:
            body = self._read_body()
            try:
                data = json.loads(body)
                heading = data.get("heading", "")
                section_id = data.get("id") or slugify(heading)
                markdown = data.get("markdown", "")
                if not section_id or not heading:
                    self._json_response(400,
                                        {"error": "id and heading required"})
                    return
                self.live_session.add_section(section_id, heading, markdown)
                self._json_response(200, {"ok": True, "section": section_id})
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response(400, {"error": str(e)})

        elif self.path == "/api/section/update" and self.live_session:
            body = self._read_body()
            try:
                data = json.loads(body)
                section_id = data.get("id") or data.get("section", "")
                markdown = data.get("markdown", "")
                if not section_id:
                    self._json_response(400,
                                        {"error": "id/section required"})
                    return
                ok = self.live_session.update_section(section_id, markdown)
                if ok:
                    self._json_response(200, {"ok": True})
                else:
                    self._json_response(404, {"error": "section not found"})
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response(400, {"error": str(e)})

        elif self.path == "/api/section/feedback" and self.live_session:
            body = self._read_body()
            try:
                data = json.loads(body)
                section_id = data.get("section", "")
                action = data.get("action", "")
                text = data.get("text", "")
                inline_comments = data.get("inline_comments", [])
                if not section_id or not action:
                    self._json_response(
                        400, {"error": "section and action required"})
                    return
                ok = self.live_session.set_feedback(
                    section_id, action, text, inline_comments)
                if ok:
                    self._json_response(200, {"ok": True})
                else:
                    self._json_response(404, {"error": "section not found"})
            except (json.JSONDecodeError, ValueError) as e:
                self._json_response(400, {"error": str(e)})

        else:
            self.send_error(404)

    def log_message(self, format: str, *args: object) -> None:
        # Suppress request logging to keep terminal clean
        pass


def _open_browser(url: str) -> None:
    """Try to open a browser; silently fail in headless environments."""
    try:
        webbrowser.open(url)
    except Exception:
        print(f"Could not open browser automatically. Visit: {url}",
              file=sys.stderr)


def main():
    if sys.version_info < (3, 10):
        print("Error: Python 3.10+ is required (for PEP 604/585 type hints).",
              file=sys.stderr)
        sys.exit(1)

    parser = argparse.ArgumentParser(
        description="Open an RFC review UI in the browser"
    )
    parser.add_argument("markdown_path", nargs="?", default=None,
                        help="Path to the markdown file "
                             "(not required in --live mode)")
    parser.add_argument("--title", default="Untitled",
                        help="Document title for the header")
    parser.add_argument("--workspace", type=Path, default=None,
                        help="Workspace directory "
                             "(default: <doc-dir>/.rfc-review/)")
    parser.add_argument("--previous-feedback", type=Path, default=None,
                        help="Path to previous iteration's feedback.json")
    parser.add_argument("--iteration", type=int, default=1,
                        help="Iteration/round number (default: 1)")
    parser.add_argument("--port", type=int, default=3118,
                        help="Server port (default: 3118)")
    parser.add_argument("--static", action="store_true",
                        help="Write standalone HTML instead of starting "
                             "a server")
    parser.add_argument("--output",
                        help="Output HTML path (only used with --static)")
    parser.add_argument("--live", action="store_true",
                        help="Start in live authoring mode "
                             "(sections added via API)")
    parser.add_argument("--sections", type=str, default=None,
                        help="JSON array of section headings "
                             "(for --live mode)")
    parser.add_argument("--no-open", action="store_true",
                        help="Don't open browser automatically "
                             "(useful in headless environments)")
    args = parser.parse_args()

    # Validate args
    if not args.live and not args.markdown_path:
        parser.error("markdown_path is required unless --live is specified")

    md_path = None
    if args.markdown_path:
        md_path = Path(args.markdown_path).expanduser().resolve()
        if not md_path.exists():
            print(f"Error: file not found: {md_path}", file=sys.stderr)
            sys.exit(1)

    # Load previous feedback if provided
    previous_feedback = None
    if args.previous_feedback:
        pf = Path(args.previous_feedback).expanduser().resolve()
        if pf.exists():
            try:
                previous_feedback = json.loads(pf.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError) as e:
                print(f"Warning: could not read previous feedback: {e}",
                      file=sys.stderr)

    if args.static:
        # --- Static mode (legacy) ---
        if not md_path:
            parser.error("markdown_path is required for --static mode")
        html = build_html(md_path, args.title, previous_feedback,
                          args.iteration, server_mode=False)
        out_path = (Path(args.output) if args.output
                    else Path(f"/tmp/dev-rfc-review-{md_path.stem}.html"))
        out_path.write_text(html, encoding="utf-8")
        if not args.no_open:
            _open_browser(out_path.as_uri())
        print(f"Review UI: {out_path}")
        return

    # --- Server mode (batch or live) ---
    if md_path:
        workspace = (args.workspace or md_path.parent / ".rfc-review").resolve()
    else:
        workspace = (args.workspace or Path.cwd() / ".rfc-review").resolve()
    workspace.mkdir(parents=True, exist_ok=True)

    feedback_path = workspace / "feedback.json"
    history_dir = workspace / "feedback-history"
    history_dir.mkdir(exist_ok=True)

    # Archive existing feedback.json before starting a new round
    if feedback_path.exists() and args.iteration > 1:
        prev_round = args.iteration - 1
        archive_dest = history_dir / f"feedback-round-{prev_round}.json"
        if not archive_dest.exists():
            archive_dest.write_text(feedback_path.read_text(encoding="utf-8"),
                                    encoding="utf-8")

    port = args.port
    kill_port(port)

    # Set up live session if in live mode
    live_session = None
    if args.live:
        sections_plan: list[str] = []
        if args.sections:
            try:
                sections_plan = json.loads(args.sections)
                if not isinstance(sections_plan, list):
                    raise ValueError("--sections must be a JSON array")
            except (json.JSONDecodeError, ValueError) as e:
                print(f"Error parsing --sections: {e}", file=sys.stderr)
                sys.exit(1)
        live_session = LiveSession(args.title, sections_plan, workspace)

    handler = partial(ReviewHandler, md_path, args.title, feedback_path,
                      previous_feedback, args.iteration, live_session)

    server = ThreadingHTTPServer(("127.0.0.1", port), handler)
    url = f"http://localhost:{port}"
    if not args.no_open:
        _open_browser(url)

    if args.live:
        print(f"RFC live authoring server running at {url}")
        print(f"Workspace: {workspace}")
        if args.sections:
            print(f"Planned sections: {len(live_session.sections)}")
        print("Agent can now push sections via POST /api/section/add")
    else:
        print(f"RFC review server running at {url}")
        print(f"Workspace: {workspace}")
        print(f"Feedback will be saved to: {feedback_path}")
        if previous_feedback:
            print(f"Showing previous feedback from: {args.previous_feedback}")

    print("Press Ctrl+C to stop the server.")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
        server.server_close()


if __name__ == "__main__":
    main()
