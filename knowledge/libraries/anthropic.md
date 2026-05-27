---
library: anthropic
last-verified-date: 2026-05-27

uses: []
implements: []
similar-to: []
notable-landmarks:
  - docs.anthropic.com 301-redirects to platform.claude.com (host migration)
  - llms.txt lists per-page .md AI-canonical variants (append .md to any doc URL)
  - Prompt caching guide is the conceptual entry point; cache_control field doc lives under it

docs:
  root: https://platform.claude.com/docs
  llms-txt: https://platform.claude.com/docs/llms.txt
  llms-txt-probed: 2026-05-27
  api-reference: https://platform.claude.com/docs/en/api
  changelog: null
  version-model: dated
  version-selector: anthropic-version header
  upgrades: null
  samples-repo: https://github.com/anthropics/anthropic-cookbook
  status-page: https://status.anthropic.com
  discord-or-forum: null
  notable-pages:
    - prompt-caching: https://platform.claude.com/docs/en/build-with-claude/prompt-caching
    - tool-use-with-prompt-caching: https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-use-with-prompt-caching
  lookup-count: 1
---

## Notes

- The docs host migrated from `docs.anthropic.com` to `platform.claude.com` (301 in place as of 2026-05-27). Always normalise to `platform.claude.com` when capturing canonical URLs.
- Trick: every doc page has an AI-canonical `.md` twin — append `.md` to the URL (e.g. `.../prompt-caching.md`). Cheaper to WebFetch than the HTML page; this is the format `llms.txt` advertises.
- No public unified changelog URL was visible from `llms.txt`; if asked about "did X change", check release notes via the API docs nav, GitHub `anthropics/anthropic-sdk-*` repo releases, or the status page.
