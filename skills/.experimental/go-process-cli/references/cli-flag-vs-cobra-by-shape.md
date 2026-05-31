---
title: Choose stdlib flag or cobra by the command surface, not by habit
tags: cli, flag, cobra, architecture
---

## Choose stdlib flag or cobra by the command surface, not by habit

Two opposite default mistakes: pulling in cobra for a tool that has one job, or hand-rolling subcommand dispatch with the global `flag` set for a tool that has grown ten commands. Pick by the *shape* of the CLI. A single action with a few flags (`myd --config x --port 8080`) needs only stdlib `flag` — no dependency, no boilerplate. A tree of verbs and nouns (`proc start`, `proc stop`, `proc ls --json`) with shared persistent flags, generated help, and completion is exactly what cobra exists for; rebuilding that on `flag` means reimplementing dispatch, help text, and flag inheritance by hand.

```go
// Single-purpose tool: stdlib flag is the right size.
func main() {
	cfg := flag.String("config", "/etc/myd.yaml", "config file path")
	port := flag.Int("port", 8080, "listen port")
	flag.Parse()
	os.Exit(run(*cfg, *port))
}
```

```go
// Multi-command tool: cobra carries the dispatch, help, and shared flags.
var rootCmd = &cobra.Command{Use: "proc", Short: "manage worker processes"}

func main() {
	rootCmd.AddCommand(startCmd, stopCmd, statusCmd)
	rootCmd.PersistentFlags().String("socket", "/run/proc.sock", "control socket")
	// ... see cli-execute-context-wires-signals for ExecuteContext
}
```

The decision is reversible but not free — migrating `flag` → cobra later is mechanical, so start with `flag` and adopt cobra when a *second* subcommand appears, not in anticipation of one. (`spf13/pflag`, which cobra uses, adds GNU-style `--long`/`-s` flags if you want those without the full framework.)

Reference: [pkg.go.dev — flag](https://pkg.go.dev/flag) · [cobra.dev](https://cobra.dev/)
