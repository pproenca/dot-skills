---
title: Run LDA on Commit Messages to Discover the Real Themes of Recent Work
impact: MEDIUM-HIGH
impactDescription: reduces 5000 quarterly commits to 5-10 named themes for retrospectives
tags: mine, lda, commit-messages, theme-discovery, retrospective
---

## Run LDA on Commit Messages to Discover the Real Themes of Recent Work

Quarterly retrospectives ask "what did we work on this quarter?" and the answer is usually a vague list assembled from PM-meeting memory. The data lives in commit messages — 5000 of them per quarter for a medium team. Run LDA on the commit-message corpus and you get a topic distribution per month, showing exactly which themes dominated and how that mix shifted. The topics often surprise: time tracked under "platform work" turns out to be 60% Stripe bug-fixing; "new features" turns out to be 70% retries on the same flaky integration. Useful for retrospectives, capacity planning, and exposing systematic problems no individual PR makes visible.

**Incorrect (manually read PR titles and group them — error-prone, biased, takes a day):**

```bash
# A PM lists "themes" from PR titles read by eye.
# Different brains group differently; the bucketing is biased
# toward what the PM expected to find. Slow and unreliable.
gh pr list --state merged --limit 500 --json title \
    | jq -r ".[].title" \
    | less
# Reviewer pattern-matches mentally and writes "themes": auth, billing, UI.
# Misses cross-cutting themes like "Stripe-induced bug-fixes" hiding inside many areas.
```

**Correct (LDA on commit-message tokens + monthly topic share):**

```python
import subprocess, re, collections
from datetime import datetime
from gensim import corpora, models

SPLIT = re.compile(r"[A-Za-z][A-Za-z']{2,}")
STOPS = {"the", "and", "for", "with", "fix", "fixes", "update", "add", "remove",
         "from", "this", "that", "merge", "pull", "request", "bump"}

# 1. Pull commit messages with month buckets
out = subprocess.check_output([
    "git", "log", "--since=12 months ago", "--pretty=format:%cI||%s||%b",
]).decode(errors="ignore")

commits: list[tuple[str, list[str]]] = []  # (yyyy-mm, tokens)
for line in out.split("\n"):
    if "||" not in line: continue
    iso, subject, body = (line.split("||", 2) + ["", ""])[:3]
    month = iso[:7]
    text = f"{subject} {body}".lower()
    tokens = [w for w in SPLIT.findall(text) if w not in STOPS and len(w) > 2]
    if tokens:
        commits.append((month, tokens))

# 2. Train LDA on the message corpus
dictionary = corpora.Dictionary([t for _, t in commits])
dictionary.filter_extremes(no_below=10, no_above=0.5)
corpus = [dictionary.doc2bow(t) for _, t in commits]
lda = models.LdaMulticore(corpus, id2word=dictionary, num_topics=8, passes=10, random_state=42)

# 3. Print topics
for tid, words in lda.print_topics(num_words=8):
    print(f"Topic {tid}: {words}")
# Topic 0: 0.08*"stripe" + 0.06*"webhook" + 0.05*"retry" + 0.04*"timeout" + 0.04*"payment"
# Topic 3: 0.07*"sitter" + 0.05*"application" + 0.04*"profile" + 0.04*"verification"
# Topic 5: 0.06*"db" + 0.05*"migration" + 0.04*"index" + 0.04*"slow"

# 4. Topic share per month → what dominated each month?
monthly = collections.defaultdict(lambda: collections.Counter())
for (month, _), bow in zip(commits, corpus):
    topic_probs = lda.get_document_topics(bow, minimum_probability=0.0)
    for tid, p in topic_probs:
        monthly[month][tid] += p

print("\nMonth-by-month dominant topics:")
for month in sorted(monthly):
    top = sorted(monthly[month].items(), key=lambda kv: -kv[1])[:3]
    print(f"  {month}: " + ", ".join(f"T{t}({s:.0f})" for t, s in top))
# 2025-11: T0(85), T3(42), T5(20)    <- Stripe firefight dominated
# 2025-12: T3(60), T0(28), T5(31)    <- sitter onboarding push
# 2026-01: T5(70), T0(31), T2(22)    <- DB migration sprint
```

**Strip Conventional Commit prefixes** (`feat:`, `fix:`, `chore:`) before training — they overwhelm the topic distribution. The script above does this with the `STOPS` set; expand it for your team's conventions.

**Cross-reference topics with PR labels** if you use them. A topic strongly correlated with the `bug` label is a recurring-bug theme. A topic correlated with `feature` is genuine new development. The mix gives you the team's real velocity ratio.

**Combine with `mine-hotspots-churn-complexity`:** topics that dominated last quarter map to the files most likely to have entered hotspot status. Run hotspots, filter by which topics modified them, and you have a defect-prediction list scoped to recent work.

**When NOT to apply:**
- Conventional Commit repos where messages are formulaic (`fix(api): bump`) — too little text per commit; mine PR bodies instead
- Repos with squash-merge only and one-word PR titles — corpus is too sparse; combine with file-path tokens to enrich signal

Reference: [Hindle et al., What's in a commit message? (MSR 2008)](https://softwareprocess.es/pubs/hindle2008MSR-CommitMessages.pdf), [Blei, Probabilistic Topic Models (CACM 2012)](https://www.cs.columbia.edu/~blei/papers/Blei2012.pdf)
