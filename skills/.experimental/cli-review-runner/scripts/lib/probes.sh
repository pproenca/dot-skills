#!/usr/bin/env bash
# probes.sh - probe functions for cli-review-runner.
# Each probe_pN function tests 1+ rules and emits NDJSON findings via
# crr_emit_finding. Probes never mutate state: they only invoke the target
# CLI with --help, --version, bogus flags on safe verbs, or </dev/null runs.
#
# Sourced by review.sh. Requires lib/common.sh to be sourced first.

set -euo pipefail

# ---------------------------------------------------------------------------
# P1 - Non-interactive operation.
# Tests: interact-no-hang-on-stdin, interact-no-input-flag, interact-flags-first,
#        interact-detect-tty, interact-no-timed-prompts, interact-no-arrow-menus,
#        input-no-prompt-fallback.
# ---------------------------------------------------------------------------
probe_p1_noninteractive() {
  local target=$1
  shift
  local subcommands=("$@")

  local top_help top_err top_rc
  top_help=$(mktemp) top_err=$(mktemp)
  top_rc=$(crr_capture "$top_help" "$top_err" "$target" --help)

  # interact-no-hang-on-stdin: top-level --help should finish quickly under </dev/null.
  if [[ $top_rc -eq $CRR_EX_TEMPFAIL ]]; then
    crr_emit_finding "interact-no-hang-on-stdin" false "P1" "HIGH" \
      "\`$target --help\` did not return within ${CRR_TIMEOUT}s when stdin was closed - the CLI may be blocking on stdin"
  else
    crr_emit_finding "interact-no-hang-on-stdin" true "P1" "HIGH" \
      "\`$target --help\` returned in <${CRR_TIMEOUT}s with </dev/null"
  fi

  # interact-no-input-flag: --help text should mention --no-input (or similar).
  if grep -qiE -- '--no-input|--non-interactive|--batch|--yes' "$top_help" 2>/dev/null; then
    crr_emit_finding "interact-no-input-flag" true "P1" "HIGH" \
      "top-level --help advertises a non-interactive flag"
  else
    crr_emit_finding "interact-no-input-flag" false "P1" "HIGH" \
      "no --no-input / --non-interactive / --batch / --yes flag found in top-level --help"
  fi

  # interact-no-timed-prompts: look for suspicious timed-prompt language in help.
  if grep -qiE 'press[[:space:]]+(any|enter|y)|seconds.*abort|counting down' "$top_help" 2>/dev/null; then
    crr_emit_finding "interact-no-timed-prompts" false "P1" "HIGH" \
      "top-level --help references a timed prompt or press-any-key screen"
  else
    crr_emit_finding "interact-no-timed-prompts" true "P1" "HIGH" \
      "no timed-prompt or press-any-key language found in --help"
  fi

  # interact-no-arrow-menus: arrow-key menus show up as "use arrow keys" hints.
  if grep -qiE 'arrow key|↑|↓|space to select|j/k to move' "$top_help" 2>/dev/null; then
    crr_emit_finding "interact-no-arrow-menus" false "P1" "CRITICAL" \
      "top-level --help mentions arrow-key or j/k selection - agents cannot drive this"
  else
    crr_emit_finding "interact-no-arrow-menus" true "P1" "CRITICAL" \
      "no arrow-key menu language found in --help"
  fi

  # interact-flags-first + interact-detect-tty + input-no-prompt-fallback:
  # invoke the first safe subcommand with no args under </dev/null. If it hangs,
  # the CLI is blocking on input. If it errors immediately, flag-first design holds.
  local probed_verb=""
  local sub
  for sub in "${subcommands[@]}"; do
    if crr_is_safe_verb "$sub"; then
      probed_verb=$sub
      break
    fi
  done

  if [[ -n "$probed_verb" ]]; then
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$probed_verb")
    if [[ $sub_rc -eq $CRR_EX_TEMPFAIL ]]; then
      crr_emit_finding "interact-flags-first" false "P1" "CRITICAL" \
        "\`$target $probed_verb\` hung >${CRR_TIMEOUT}s under </dev/null - inputs are probably collected via prompt"
      crr_emit_finding "interact-detect-tty" false "P1" "CRITICAL" \
        "\`$target $probed_verb\` prompted without checking isatty() - it hung when stdin was closed"
      crr_emit_finding "input-no-prompt-fallback" false "P1" "MEDIUM-HIGH" \
        "\`$target $probed_verb\` fell back to an interactive prompt when flags were missing"
    else
      crr_emit_finding "interact-flags-first" true "P1" "CRITICAL" \
        "\`$target $probed_verb\` returned in <${CRR_TIMEOUT}s under </dev/null (exit=$sub_rc)"
      crr_emit_finding "interact-detect-tty" true "P1" "CRITICAL" \
        "\`$target $probed_verb\` did not block under </dev/null - TTY check is in effect"
      crr_emit_finding "input-no-prompt-fallback" true "P1" "MEDIUM-HIGH" \
        "\`$target $probed_verb\` errored out instead of prompting when flags were missing"
    fi
    rm -f "$sub_out" "$sub_err"
  fi

  rm -f "$top_help" "$top_err"
}

# ---------------------------------------------------------------------------
# P2 - Layered help.
# Tests: help-per-subcommand, help-no-flag-required, help-layered-discovery.
# ---------------------------------------------------------------------------
probe_p2_help_layered() {
  local target=$1
  shift
  local subcommands=("$@")

  local top_help top_err top_rc
  top_help=$(mktemp) top_err=$(mktemp)
  top_rc=$(crr_capture "$top_help" "$top_err" "$target" --help)

  # help-layered-discovery: top-level help should be navigational (under ~150 lines).
  local line_count
  line_count=$(wc -l <"$top_help" | tr -d ' ')
  if [[ $top_rc -eq $CRR_EX_TEMPFAIL ]]; then
    crr_emit_finding "help-layered-discovery" false "P2" "HIGH" \
      "top-level --help timed out, cannot evaluate layering"
  elif (( line_count > 200 )); then
    crr_emit_finding "help-layered-discovery" false "P2" "HIGH" \
      "top-level --help is $line_count lines - dumps everything instead of acting as a nav index"
  elif (( line_count < 10 )); then
    crr_emit_finding "help-layered-discovery" false "P2" "HIGH" \
      "top-level --help is only $line_count lines - probably missing a subcommand index"
  else
    crr_emit_finding "help-layered-discovery" true "P2" "HIGH" \
      "top-level --help is $line_count lines - fits a navigational shape"
  fi

  # help-no-flag-required: running the CLI with zero args should print help, not start work.
  local zero_out zero_err zero_rc
  zero_out=$(mktemp) zero_err=$(mktemp)
  zero_rc=$(crr_capture "$zero_out" "$zero_err" "$target")
  if [[ $zero_rc -eq $CRR_EX_TEMPFAIL ]]; then
    crr_emit_finding "help-no-flag-required" false "P2" "HIGH" \
      "\`$target\` (no args) hung >${CRR_TIMEOUT}s - it is probably prompting for input instead of showing help"
  elif grep -qiE 'usage:|commands?:|options?:' "$zero_out" "$zero_err" 2>/dev/null; then
    crr_emit_finding "help-no-flag-required" true "P2" "HIGH" \
      "\`$target\` (no args) printed usage-shaped output"
  else
    crr_emit_finding "help-no-flag-required" false "P2" "HIGH" \
      "\`$target\` (no args) did not print usage output (exit=$zero_rc)"
  fi
  rm -f "$zero_out" "$zero_err"

  # help-per-subcommand: each safe subcommand should have its own --help that succeeds.
  local total=0 with_help=0
  local sub
  for sub in "${subcommands[@]}"; do
    if ! crr_is_safe_verb "$sub" && ! crr_is_destructive_verb "$sub"; then
      continue  # unclassified - skip to keep the probe read-only
    fi
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$sub" --help)
    (( total+=1 ))
    if [[ $sub_rc -eq 0 ]] && [[ -s "$sub_out" ]]; then
      (( with_help+=1 ))
    fi
    rm -f "$sub_out" "$sub_err"
  done
  if (( total == 0 )); then
    crr_emit_finding "help-per-subcommand" true "P2" "HIGH" \
      "no classifiable subcommands discovered - skipping per-subcommand help check"
  elif (( with_help == total )); then
    crr_emit_finding "help-per-subcommand" true "P2" "HIGH" \
      "all $total probed subcommands have their own --help"
  else
    crr_emit_finding "help-per-subcommand" false "P2" "HIGH" \
      "$with_help of $total probed subcommands have a working --help"
  fi

  rm -f "$top_help" "$top_err"
}

# ---------------------------------------------------------------------------
# P3 - Help examples and discoverability.
# Tests: help-examples-in-help, help-flag-summary, help-suggest-next-steps.
# ---------------------------------------------------------------------------
probe_p3_help_examples() {
  local target=$1
  shift
  local subcommands=("$@")

  local with_examples=0 with_next=0 total=0 with_flag_pair=0
  local sub
  for sub in "${subcommands[@]}"; do
    if ! crr_is_safe_verb "$sub" && ! crr_is_destructive_verb "$sub"; then
      continue
    fi
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$sub" --help)
    if [[ $sub_rc -ne 0 ]] || [[ ! -s "$sub_out" ]]; then
      rm -f "$sub_out" "$sub_err"
      continue
    fi
    (( total+=1 ))
    if grep -qiE '^[[:space:]]*example' "$sub_out" 2>/dev/null; then
      (( with_examples+=1 ))
    fi
    if grep -qiE 'see also|next|then run|you can now|related' "$sub_out" 2>/dev/null; then
      (( with_next+=1 ))
    fi
    # help-flag-summary: look for at least one line with both a short and long form, like "-v, --verbose".
    if grep -qE -- '-[a-zA-Z],[[:space:]]+--[a-zA-Z]' "$sub_out" 2>/dev/null; then
      (( with_flag_pair+=1 ))
    fi
    rm -f "$sub_out" "$sub_err"
  done

  if (( total == 0 )); then
    crr_emit_finding "help-examples-in-help" true "P3" "CRITICAL" \
      "no subcommands discovered to probe - defaulting to pass, run with explicit --subcommand for a real check"
    crr_emit_finding "help-suggest-next-steps" true "P3" "HIGH" \
      "no subcommands discovered to probe"
    crr_emit_finding "help-flag-summary" true "P3" "HIGH" \
      "no subcommands discovered to probe"
    return 0
  fi

  if (( with_examples == total )); then
    crr_emit_finding "help-examples-in-help" true "P3" "CRITICAL" \
      "all $total subcommands include an Examples section in --help"
  elif (( with_examples > 0 )); then
    crr_emit_finding "help-examples-in-help" false "P3" "CRITICAL" \
      "$with_examples of $total subcommands have an Examples section - every subcommand --help should"
  else
    crr_emit_finding "help-examples-in-help" false "P3" "CRITICAL" \
      "zero subcommands include an Examples section in --help - add one ending each help text"
  fi

  # Looser threshold (majority rather than all) because next-steps guidance is
  # a softer signal than Examples or flag-pair forms: a well-designed CLI may
  # legitimately omit "See also" from terminal-action subcommands (e.g., 'login',
  # 'logout'). Penalizing partial coverage here would produce noisy false fails.
  if (( with_next >= total / 2 )); then
    crr_emit_finding "help-suggest-next-steps" true "P3" "HIGH" \
      "$with_next of $total subcommands mention next steps / related commands"
  else
    crr_emit_finding "help-suggest-next-steps" false "P3" "HIGH" \
      "only $with_next of $total subcommands suggest next steps - add 'See also:' or 'Next:' sections"
  fi

  if (( with_flag_pair == total )); then
    crr_emit_finding "help-flag-summary" true "P3" "HIGH" \
      "all $total subcommands list short+long forms like -v, --verbose"
  elif (( with_flag_pair > 0 )); then
    crr_emit_finding "help-flag-summary" false "P3" "HIGH" \
      "$with_flag_pair of $total subcommands list short+long flag forms"
  else
    crr_emit_finding "help-flag-summary" false "P3" "HIGH" \
      "no subcommand --help lists both short and long flag forms"
  fi
}

# ---------------------------------------------------------------------------
# P4 - Actionable errors.
# Tests: err-exit-fast-on-missing-required, err-actionable-fix,
#        err-include-example-invocation, err-no-stack-traces-by-default.
# Strategy: pick the first safe subcommand and invoke it with a bogus flag
# that should never be valid. Inspect stderr for the expected properties.
# ---------------------------------------------------------------------------
probe_p4_errors() {
  local target=$1
  shift
  local subcommands=("$@")

  local probed_verb=""
  local sub
  for sub in "${subcommands[@]}"; do
    if crr_is_safe_verb "$sub"; then
      probed_verb=$sub
      break
    fi
  done

  local err_file out_file rc bogus="--definitely-not-a-real-flag-xyz123"
  out_file=$(mktemp) err_file=$(mktemp)
  if [[ -n "$probed_verb" ]]; then
    rc=$(crr_capture "$out_file" "$err_file" "$target" "$probed_verb" "$bogus")
  else
    rc=$(crr_capture "$out_file" "$err_file" "$target" "$bogus")
  fi

  # err-exit-fast-on-missing-required: should exit non-zero, under timeout.
  if [[ $rc -eq $CRR_EX_TEMPFAIL ]]; then
    crr_emit_finding "err-exit-fast-on-missing-required" false "P4" "HIGH" \
      "bogus flag hung >${CRR_TIMEOUT}s instead of erroring fast"
  elif [[ $rc -eq 0 ]]; then
    crr_emit_finding "err-exit-fast-on-missing-required" false "P4" "HIGH" \
      "bogus flag '$bogus' exited 0 - the CLI silently accepted nonsense"
  else
    crr_emit_finding "err-exit-fast-on-missing-required" true "P4" "HIGH" \
      "bogus flag exited $rc quickly under ${CRR_TIMEOUT}s"
  fi

  local err_combined
  err_combined="$(cat "$err_file" "$out_file" 2>/dev/null || true)"

  # err-actionable-fix: error mentions a fix, usage hint, or valid values.
  if echo "$err_combined" | grep -qiE 'usage:|try:|example:|valid values|did you mean'; then
    crr_emit_finding "err-actionable-fix" true "P4" "HIGH" \
      "error output contains a usage hint / try / example / valid-values block"
  else
    crr_emit_finding "err-actionable-fix" false "P4" "HIGH" \
      "error for '$bogus' did not suggest a fix - add 'Try: ...' or list valid values"
  fi

  # err-include-example-invocation: error includes an example command.
  # Look for (a) a line starting with the target's basename followed by a space or flag,
  # or (b) a line starting with `$ ` as a shell prompt. The earlier heuristic also matched
  # any indented lowercase line, which false-positived on plain descriptive prose.
  local cli_base=${target##*/}
  if echo "$err_combined" | grep -qE "^[[:space:]]*(\\\$[[:space:]]+)?${cli_base}[[:space:]]+(-|[a-z])" 2>/dev/null; then
    crr_emit_finding "err-include-example-invocation" true "P4" "HIGH" \
      "error output contains an example invocation starting with '${cli_base}'"
  else
    crr_emit_finding "err-include-example-invocation" false "P4" "HIGH" \
      "error output has no example invocation - append '${cli_base} $probed_verb --flag value'"
  fi

  # err-no-stack-traces-by-default: no raw language trace dumped by default.
  if echo "$err_combined" | grep -qiE 'traceback \(most recent|^[[:space:]]*at [a-z].*:[0-9]+|^[[:space:]]*File "[^"]+", line|panic: '; then
    crr_emit_finding "err-no-stack-traces-by-default" false "P4" "MEDIUM-HIGH" \
      "error output contains a raw stack trace - gate traces behind --debug / --verbose"
  else
    crr_emit_finding "err-no-stack-traces-by-default" true "P4" "MEDIUM-HIGH" \
      "error output has no raw stack trace in the default path"
  fi

  rm -f "$out_file" "$err_file"
}

# ---------------------------------------------------------------------------
# P5 - stderr channeling.
# Tests: err-stderr-not-stdout.
# ---------------------------------------------------------------------------
probe_p5_stderr() {
  local target=$1
  local out_file err_file rc
  out_file=$(mktemp) err_file=$(mktemp)
  rc=$(crr_capture "$out_file" "$err_file" "$target" --definitely-not-a-real-flag-xyz123)

  if [[ $rc -eq 0 ]]; then
    crr_emit_finding "err-stderr-not-stdout" true "P5" "HIGH" \
      "target accepted bogus flag with exit 0 - cannot evaluate stderr routing"
  elif [[ -s "$err_file" ]] && [[ ! -s "$out_file" ]]; then
    crr_emit_finding "err-stderr-not-stdout" true "P5" "HIGH" \
      "error text landed on stderr (fd 2); stdout was empty"
  elif [[ -s "$err_file" ]] && [[ -s "$out_file" ]]; then
    crr_emit_finding "err-stderr-not-stdout" false "P5" "HIGH" \
      "error text appeared on BOTH stdout and stderr - split so stdout stays clean for pipes"
  else
    crr_emit_finding "err-stderr-not-stdout" false "P5" "HIGH" \
      "error text was on stdout, not stderr - redirecting will corrupt piped data"
  fi

  rm -f "$out_file" "$err_file"
}

# ---------------------------------------------------------------------------
# P6 - Exit codes.
# Tests: err-non-zero-exit-codes.
# Strategy: invoke with bogus flag; compare to --help exit (expected 0).
# Ideal: bogus exits 2 (POSIX) or 64 (sysexits.h). Any non-zero code != 0 passes.
# ---------------------------------------------------------------------------
probe_p6_exit_codes() {
  local target=$1
  local out_file err_file help_rc bad_rc
  out_file=$(mktemp) err_file=$(mktemp)

  help_rc=$(crr_capture "$out_file" "$err_file" "$target" --help)
  bad_rc=$(crr_capture "$out_file" "$err_file" "$target" --definitely-not-a-real-flag-xyz123)

  if [[ $help_rc -ne 0 ]]; then
    crr_emit_finding "err-non-zero-exit-codes" false "P6" "HIGH" \
      "\`$target --help\` exited $help_rc - --help should exit 0"
  elif [[ $bad_rc -eq 0 ]]; then
    crr_emit_finding "err-non-zero-exit-codes" false "P6" "HIGH" \
      "bogus flag exited 0 - failures must use distinct non-zero codes"
  elif [[ $bad_rc -eq 1 ]]; then
    crr_emit_finding "err-non-zero-exit-codes" false "P6" "HIGH" \
      "bogus flag exited 1 - usage errors should use 2 (POSIX) or 64 (sysexits.h) for distinguishability"
  else
    crr_emit_finding "err-non-zero-exit-codes" true "P6" "HIGH" \
      "bogus flag exited $bad_rc (distinct from --help's 0) - agents can branch on this"
  fi

  rm -f "$out_file" "$err_file"
}

# ---------------------------------------------------------------------------
# P7 - stdin / input composition.
# Tests: input-accept-stdin-dash, input-flags-over-positional.
# ---------------------------------------------------------------------------
probe_p7_stdin() {
  local target=$1
  shift
  local subcommands=("$@")

  local top_help top_err
  top_help=$(mktemp) top_err=$(mktemp)
  crr_capture "$top_help" "$top_err" "$target" --help >/dev/null

  # input-accept-stdin-dash: look for `-` as filename in any subcommand help.
  local found_dash=0 checked=0
  local sub
  for sub in "${subcommands[@]}"; do
    if ! crr_is_safe_verb "$sub" && ! crr_is_destructive_verb "$sub"; then
      continue
    fi
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$sub" --help)
    (( checked+=1 ))
    if [[ $sub_rc -eq 0 ]] && grep -qE '(stdin|STDIN|"-"|`-`| - [[:space:]])' "$sub_out" 2>/dev/null; then
      (( found_dash+=1 ))
    fi
    rm -f "$sub_out" "$sub_err"
  done

  if (( checked == 0 )); then
    crr_emit_finding "input-accept-stdin-dash" true "P7" "HIGH" \
      "no subcommands discovered - skipping stdin-dash check"
  elif (( found_dash > 0 )); then
    crr_emit_finding "input-accept-stdin-dash" true "P7" "HIGH" \
      "$found_dash of $checked subcommands document '-' or stdin support in --help"
  else
    crr_emit_finding "input-accept-stdin-dash" false "P7" "HIGH" \
      "no subcommand --help documents '-' for stdin - pipelines need this convention"
  fi

  # input-flags-over-positional: top-level usage heavy on <POSITIONAL> is a smell.
  local pos_count flag_count
  pos_count=$(grep -oE '<[A-Z][A-Z_0-9]*>' "$top_help" 2>/dev/null | wc -l | tr -d ' ')
  flag_count=$(grep -oE -- '--[a-z][a-z-]+' "$top_help" 2>/dev/null | wc -l | tr -d ' ')
  if (( flag_count == 0 && pos_count == 0 )); then
    crr_emit_finding "input-flags-over-positional" true "P7" "HIGH" \
      "top-level --help has no positionals and no flags - too little to judge"
  elif (( pos_count > flag_count )); then
    crr_emit_finding "input-flags-over-positional" false "P7" "HIGH" \
      "top-level --help shows $pos_count positional placeholders vs $flag_count flags - prefer named flags"
  else
    crr_emit_finding "input-flags-over-positional" true "P7" "HIGH" \
      "top-level --help shows $flag_count flags vs $pos_count positionals"
  fi

  rm -f "$top_help" "$top_err"
}

# ---------------------------------------------------------------------------
# P8 - Structured output.
# Tests: output-json-flag, output-respect-no-color.
# ---------------------------------------------------------------------------
probe_p8_output() {
  local target=$1
  shift
  local subcommands=("$@")

  local top_help top_err
  top_help=$(mktemp) top_err=$(mktemp)
  crr_capture "$top_help" "$top_err" "$target" --help >/dev/null

  # output-json-flag: advertise or support --json somewhere.
  local has_json_help=0 json_runs_ok=0 json_checked=0
  if grep -qE -- '--json|--format[[:space:]=]?json' "$top_help" 2>/dev/null; then
    has_json_help=1
  fi

  # Try running the first safe list-like subcommand with --json.
  local sub
  for sub in "${subcommands[@]}"; do
    if ! crr_is_safe_verb "$sub"; then
      continue
    fi
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$sub" --json)
    (( json_checked+=1 ))
    if [[ $sub_rc -eq 0 ]] && head -c 1 "$sub_out" 2>/dev/null | grep -qE '[{\[]'; then
      (( json_runs_ok+=1 ))
    fi
    rm -f "$sub_out" "$sub_err"
    break  # one is enough for the smoke test
  done

  if (( json_runs_ok > 0 )); then
    crr_emit_finding "output-json-flag" true "P8" "MEDIUM-HIGH" \
      "--json flag produced JSON-shaped output on a safe subcommand"
  elif (( has_json_help == 1 )); then
    crr_emit_finding "output-json-flag" true "P8" "MEDIUM-HIGH" \
      "--json is advertised in --help (smoke invocation skipped or returned non-JSON)"
  else
    crr_emit_finding "output-json-flag" false "P8" "MEDIUM-HIGH" \
      "no --json flag found in --help and no JSON output observed"
  fi

  # output-respect-no-color: run top-level --help with NO_COLOR=1 and check for ANSI.
  local nc_out nc_err
  nc_out=$(mktemp) nc_err=$(mktemp)
  NO_COLOR=1 crr_with_timeout "${CRR_TIMEOUT:-5}" "$target" --help \
    >"$nc_out" 2>"$nc_err" </dev/null || true
  if grep -q $'\x1b\[' "$nc_out" 2>/dev/null; then
    crr_emit_finding "output-respect-no-color" false "P8" "MEDIUM" \
      "target emitted ANSI escape sequences even with NO_COLOR=1 set"
  else
    crr_emit_finding "output-respect-no-color" true "P8" "MEDIUM" \
      "target suppressed ANSI escapes when NO_COLOR=1 was set"
  fi

  rm -f "$top_help" "$top_err" "$nc_out" "$nc_err"
}

# ---------------------------------------------------------------------------
# P9 - Destructive safety.
# Tests: safe-dry-run-flag, safe-force-bypass-flag, safe-no-prompts-with-no-input.
# Only inspects --help of destructive verbs. Never runs the verb itself.
# ---------------------------------------------------------------------------
probe_p9_destructive() {
  local target=$1
  shift
  local subcommands=("$@")

  local destructive_found=0 with_dry_run=0 with_force=0 with_no_input=0
  local sub
  for sub in "${subcommands[@]}"; do
    if ! crr_is_destructive_verb "$sub"; then
      continue
    fi
    (( destructive_found+=1 ))
    local sub_out sub_err sub_rc
    sub_out=$(mktemp) sub_err=$(mktemp)
    sub_rc=$(crr_capture "$sub_out" "$sub_err" "$target" "$sub" --help)
    if [[ $sub_rc -eq 0 ]] && [[ -s "$sub_out" ]]; then
      if grep -qE -- '--dry-run|-n[[:space:]]|dry.run' "$sub_out"; then
        (( with_dry_run+=1 ))
      fi
      if grep -qE -- '--force|--yes|-f[[:space:]]|-y[[:space:]]' "$sub_out"; then
        (( with_force+=1 ))
      fi
      if grep -qE -- '--no-input|--non-interactive|--batch' "$sub_out"; then
        (( with_no_input+=1 ))
      fi
    fi
    rm -f "$sub_out" "$sub_err"
  done

  if (( destructive_found == 0 )); then
    crr_emit_finding "safe-dry-run-flag" true "P9" "HIGH" \
      "no destructive verbs discovered - skipping dry-run check"
    crr_emit_finding "safe-force-bypass-flag" true "P9" "HIGH" \
      "no destructive verbs discovered - skipping force-bypass check"
    crr_emit_finding "safe-no-prompts-with-no-input" true "P9" "HIGH" \
      "no destructive verbs discovered - skipping no-input check"
    return 0
  fi

  if (( with_dry_run == destructive_found )); then
    crr_emit_finding "safe-dry-run-flag" true "P9" "HIGH" \
      "all $destructive_found destructive verbs advertise --dry-run in --help"
  else
    crr_emit_finding "safe-dry-run-flag" false "P9" "HIGH" \
      "$with_dry_run of $destructive_found destructive verbs advertise --dry-run"
  fi

  if (( with_force == destructive_found )); then
    crr_emit_finding "safe-force-bypass-flag" true "P9" "HIGH" \
      "all $destructive_found destructive verbs advertise --yes/--force"
  else
    crr_emit_finding "safe-force-bypass-flag" false "P9" "HIGH" \
      "$with_force of $destructive_found destructive verbs advertise --yes or --force"
  fi

  if (( with_no_input > 0 )); then
    crr_emit_finding "safe-no-prompts-with-no-input" true "P9" "HIGH" \
      "$with_no_input of $destructive_found destructive verbs reference --no-input"
  else
    crr_emit_finding "safe-no-prompts-with-no-input" false "P9" "HIGH" \
      "no destructive verb --help mentions --no-input / --non-interactive"
  fi
}

# ---------------------------------------------------------------------------
# P10 - Command structure.
# Tests: struct-resource-verb, struct-flag-order-independent,
#        struct-no-hidden-subcommand-catchall, struct-standard-flag-names.
# ---------------------------------------------------------------------------
probe_p10_structure() {
  local target=$1
  shift
  local subcommands=("$@")

  local top_help top_err
  top_help=$(mktemp) top_err=$(mktemp)
  crr_capture "$top_help" "$top_err" "$target" --help >/dev/null

  # struct-standard-flag-names: --help and --version must both be present.
  local standard_flags=("--help" "--version")
  local missing=()
  local f
  for f in "${standard_flags[@]}"; do
    if ! grep -qE -- "$f" "$top_help" 2>/dev/null; then
      missing+=("$f")
    fi
  done
  if (( ${#missing[@]} == 0 )); then
    crr_emit_finding "struct-standard-flag-names" true "P10" "MEDIUM" \
      "top-level --help advertises both --help and --version"
  else
    crr_emit_finding "struct-standard-flag-names" false "P10" "MEDIUM" \
      "top-level --help missing: ${missing[*]}"
  fi

  # struct-no-hidden-subcommand-catchall: unknown subcommand should error,
  # not silently succeed or run some default handler.
  local bogus_out bogus_err bogus_rc
  bogus_out=$(mktemp) bogus_err=$(mktemp)
  bogus_rc=$(crr_capture "$bogus_out" "$bogus_err" "$target" "__crr_not_a_subcommand_zz")
  if [[ $bogus_rc -eq 0 ]]; then
    crr_emit_finding "struct-no-hidden-subcommand-catchall" false "P10" "MEDIUM" \
      "unknown subcommand '__crr_not_a_subcommand_zz' exited 0 - likely a catchall"
  else
    crr_emit_finding "struct-no-hidden-subcommand-catchall" true "P10" "MEDIUM" \
      "unknown subcommand exited $bogus_rc as expected"
  fi
  rm -f "$bogus_out" "$bogus_err"

  # struct-flag-order-independent: --help should work before and after a subcommand.
  # Only run if we have at least one safe subcommand to test with.
  local probed_verb=""
  local sub
  for sub in "${subcommands[@]}"; do
    if crr_is_safe_verb "$sub"; then
      probed_verb=$sub
      break
    fi
  done
  if [[ -n "$probed_verb" ]]; then
    local a_out a_err a_rc b_out b_err b_rc
    a_out=$(mktemp) a_err=$(mktemp) b_out=$(mktemp) b_err=$(mktemp)
    a_rc=$(crr_capture "$a_out" "$a_err" "$target" --help "$probed_verb")
    b_rc=$(crr_capture "$b_out" "$b_err" "$target" "$probed_verb" --help)
    if [[ $a_rc -eq 0 && $b_rc -eq 0 ]]; then
      crr_emit_finding "struct-flag-order-independent" true "P10" "MEDIUM" \
        "--help works both before and after '$probed_verb'"
    elif [[ $b_rc -eq 0 && $a_rc -ne 0 ]]; then
      crr_emit_finding "struct-flag-order-independent" false "P10" "MEDIUM" \
        "'$target --help $probed_verb' failed (rc=$a_rc) but '$target $probed_verb --help' succeeded - flag order matters"
    else
      crr_emit_finding "struct-flag-order-independent" true "P10" "MEDIUM" \
        "both flag orders behaved consistently (a=$a_rc, b=$b_rc)"
    fi
    rm -f "$a_out" "$a_err" "$b_out" "$b_err"
  else
    crr_emit_finding "struct-flag-order-independent" true "P10" "MEDIUM" \
      "no safe subcommand available to probe flag order"
  fi

  # struct-resource-verb: look for `<resource> <verb>` pairs across subcommands.
  # Heuristic: if two subcommands share a prefix separator (colon or space) and
  # end in a common verb (list, get, delete), call it uniform.
  local verbs_seen=() resource_count=0
  for sub in "${subcommands[@]}"; do
    case "$sub" in
      *:list|*:get|*:show|*:delete|*:create) (( resource_count+=1 )) ;;
    esac
    verbs_seen+=("$sub")
  done
  if (( resource_count >= 2 )); then
    crr_emit_finding "struct-resource-verb" true "P10" "MEDIUM" \
      "$resource_count subcommands follow a resource:verb naming shape"
  elif (( ${#verbs_seen[@]} < 3 )); then
    crr_emit_finding "struct-resource-verb" true "P10" "MEDIUM" \
      "fewer than 3 subcommands discovered - resource-verb shape is not applicable"
  else
    crr_emit_finding "struct-resource-verb" false "P10" "MEDIUM" \
      "no resource:verb shape detected in discovered subcommands - consider 'service list', 'service get' style"
  fi

  rm -f "$top_help" "$top_err"
}
