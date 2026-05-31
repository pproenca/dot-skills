---
title: Use a FlagSet per subcommand when staying on the stdlib
tags: cli, flag, subcommands
---

## Use a FlagSet per subcommand when staying on the stdlib

When a tool has a couple of subcommands but you don't want a framework, the trap is leaning on the global `flag.CommandLine` set — every subcommand's flags collide in one namespace, and `flag.Parse()` chokes on the verb. The stdlib already supports subcommands cleanly: `os.Args[1]` selects the command, and each command gets its own `flag.NewFlagSet` parsing `os.Args[2:]`. Each set has independent flags, its own usage, and its own error handling.

```go
func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: proc <start|stop> [flags]")
		os.Exit(2)
	}

	switch os.Args[1] {
	case "start":
		fs := flag.NewFlagSet("start", flag.ExitOnError)
		port := fs.Int("port", 8080, "listen port")
		_ = fs.Parse(os.Args[2:]) // parse only this subcommand's args
		os.Exit(runStart(*port))
	case "stop":
		fs := flag.NewFlagSet("stop", flag.ExitOnError)
		force := fs.Bool("force", false, "SIGKILL instead of SIGTERM")
		_ = fs.Parse(os.Args[2:])
		os.Exit(runStop(*force))
	default:
		fmt.Fprintf(os.Stderr, "unknown command %q\n", os.Args[1])
		os.Exit(2)
	}
}
```

This stays dependency-free and scales to a handful of commands. Once subcommands need shared persistent flags, nested verbs, or generated completion, that is the signal to switch to cobra rather than grow this switch into a parser — see [Choose stdlib flag or cobra by the command surface](cli-flag-vs-cobra-by-shape.md).

Reference: [pkg.go.dev — flag.NewFlagSet](https://pkg.go.dev/flag#NewFlagSet)
