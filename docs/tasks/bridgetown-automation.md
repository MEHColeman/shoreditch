# Exercise `bridgetown.automation.rb` against a fresh site

**Status:** in progress
**Branch:** feat/bridgetown-automation
**Worktree:** ../shoreditch-worktrees/bridgetown-automation
**Base:** master
**PR:** https://github.com/MEHColeman/shoreditch/pull/3
**Issue:** none
**Todo:** "Exercise `bridgetown.automation.rb` against a fresh site" in docs/TODO.md
**Planned at:** 795ba475b54f34403fb32fa6a5a62b2fa8e8d327

## Context

The automation is the headline install route — the README and the demo's
configuration post both tell people to run `bin/bridgetown apply` — and it has
never been executed once. The gem install path is proven by hand (`demo/` and
`MEHColeman/blog` both consume the theme) but the automation itself is not,
and it gates the RubyGems publish: releasing an install route that has never
run is how a first impression gets burned. Until the 2026-08-08 merge its
accent prompt fed a dead option, so testing it earlier would have proven a
path leading nowhere.

Decisions made at planning (Mark, 2026-08-08): pre-seed the fresh site's
Gemfile with a `path:` source rather than deferring behind the publish or
editing the automation; defects found are fixed on this branch, not just
filed; the PTY harness is kept as a committed script, re-runnable after the
publish and feeding the "Consider a test suite" task.

## What's already known

- The automation is 58 lines: `add_gem "shoreditch"`, two `ask()` prompts
  (accent, logo legend), an `add_initializer :shoreditch` whose block returns
  `""` when both answers are blank, a `create_file "src/_posts/_defaults.yml",
  force: false`, and a `say` with next steps.
- **`add_gem "shoreditch"` resolves against RubyGems, where the gem is not
  published** (404 as of 5 Aug 2026). A truly fresh site fails at step one
  today. The exercise pre-seeds `gem "shoreditch", path: <this checkout>` into
  the fresh Gemfile first and observes what `add_gem` does when the gem is
  already present (`bundle add` may error — that behaviour is part of the
  evidence). The pure RubyGems path stays unproven until publish; the publish
  TODO item gains a re-run step without the pre-seed.
- Named unknown from the TODO: whether the blank-answer path writes a clean
  `init :shoreditch` or something malformed — the block returns `""` and what
  Bridgetown concatenates around it has never been observed.
- Anticipated defect #1: prompt answers are interpolated raw into generated
  Ruby (`accent "#{accent}"`, line 16). An answer containing `"` produces a
  syntactically broken initializer. The theme validates accent at render time
  (`css_colour`), but the automation can still write unparseable Ruby.
- Anticipated defect #2: a fresh `bridgetown new` site ships the starter
  frontend whose `main`/`body` rules trample the theme — the exact bug that
  hid the theme on the demo for months (seed.md "Traps"). The automation does
  not touch `frontend/styles/index.css`, so an automation-installed site
  likely renders broken out of the box. Verify, and fix in the automation
  (empty the starter stylesheet, or at minimum warn in the closing `say`).
- The automation only defaults post layouts (`src/_posts/_defaults.yml`); the
  fresh site's index keeps the starter layout. So "renders the sidebar" is
  checked on a **built post page**, not the index.
- Environment: no global bridgetown gem is assumed — scaffold the fresh site
  through the demo's bundle (`BUNDLE_GEMFILE=demo/Gemfile bundle exec
  bridgetown new ...`). Node 22 is required for the fresh site's esbuild too
  (`nvm use 22`, `npm install` in the test site). `ask()` needs a PTY —
  that is why this was never run in a background shell; the script drives it
  with Ruby's `PTY` module or `expect`.

## Registry delta

This repo's doc set (no docs/system/ split):

- `README.md` — unchanged unless a fix changes user-visible automation
  behaviour, in which case its install section is updated to match.
- `docs/seed.md` — gains the exercise script in the commands table.
- `docs/acceptance.md` — written at closeout from the criteria below.
- `docs/TODO.md` — publish item gains the no-pre-seed re-run step; anything
  found but out of scope is filed with context.
- `CHANGELOG.md` — entries for any automation fixes this branch makes.
- `docs/journal.md` — the exercise's findings, at closeout.

## Approach

1. Write `scripts/exercise-automation.sh`: scaffolds a fresh ERB Bridgetown
   site in a temp dir, pre-seeds the `path:` gem line, `npm install`s on Node
   22, then drives `bin/bridgetown apply <checkout>` through a PTY twice —
   once answering both prompts (`#aa3355`, `TEST`), once sending two blank
   lines — and asserts on the results (initializer parses via `ruby -c`,
   expected settings present, site builds, a built post contains
   `sd-sidebar`). Exit 0 only when every assertion holds; print what failed
   otherwise.
2. Run it. Record verbatim output in the progress log — especially the
   `add_gem`-against-existing-gem behaviour and the blank-path initializer.
3. Add the quote-in-answer probe (accent answered as `#aa3355"`) as a third
   scripted path asserting the initializer still parses or the answer is
   rejected.
4. Fix what the runs prove broken — expected: answer sanitisation, the
   starter-frontend trample, possibly the blank-path initializer — re-running
   the script after each fix until clean. CHANGELOG entries as fixes land.
5. Update the publish TODO item (re-run without pre-seed after publishing)
   and file anything out of scope.

## Acceptance criteria

- [x] The living set is true of the tree again: every document named in the
      registry delta is updated on this branch, and the ones named unchanged
      still read true
- [x] `scripts/exercise-automation.sh` exists, is committed, and exits 0: it
      scaffolds a fresh site, pre-seeds the path-sourced gem, and drives the
      apply with answers piped on stdin for the answered, blank, and
      quote-probe paths *(amended from "through a PTY" with Mark's agreement
      2026-08-08 — the exercise disproved the PTY premise; the point was
      non-interactive and repeatable, which stdin piping is)*
- [x] Answered path: `config/initializers.rb` passes `ruby -c` and carries
      `init :shoreditch` with `accent "#aa3355"` and `logo_legend "TEST"`;
      the site builds and a built post page contains `sd-sidebar`
- [x] Blank path: `config/initializers.rb` passes `ruby -c` and carries a
      clean `init :shoreditch`; the site builds and a built post page
      contains `sd-sidebar`
- [x] Hostile-answer path: an answer containing a quote, a backslash or a
      `#{…}` interpolation cannot produce a non-parsing initializer, cannot
      execute at site load, and cannot reach the generated file — such answers
      are rejected (verified by the `nasty` path: no payload in the
      initializer, site builds) *(broadened 2026-08-08 from "quote-probe …
      sanitised or rejected" during remediation — the review found escaping is
      unreliable through Bridgetown's insertion, so rejection is the fix; the
      criterion's intent, no injection, is unchanged)*
- [x] An automation-installed site's built post page is not trampled by the
      starter stylesheet — verified by assertion or, if judged a
      documentation matter instead, by Mark waiving this criterion in review
- [x] The publish TODO item carries the post-publish re-run step, and every
      defect found is either fixed on this branch (script re-run clean) or
      filed in docs/TODO.md with context

## Verification

```
scripts/exercise-automation.sh          # exits 0, prints per-path results
git log --oneline master..HEAD          # fixes visible as commits
grep -n "re-run" docs/TODO.md           # publish item carries the step
```

## Progress log

- Environment probed: Bridgetown 2.2.2 via the demo bundle, Ruby 3.4.10,
  `pty`+`expect` stdlib present, worktree demo bundle satisfied.
- `scripts/exercise-automation.sh` written: pristine scaffold once (clean
  bundler env via `insite()` — `bundle exec` pollutes `BUNDLE_GEMFILE` et al
  for child processes, so every in-site command strips them), pre-seed
  path-sourced gem, copy per path, assertions per path.
- Discovery: `bin/bridgetown apply <directory>` dies with EISDIR —
  Freyia `IO.read`s the argument raw. The target must be the automation file
  or a URL. All shipped docs use the GitHub-URL form, so no doc was wrong —
  only the TODO's assumed local invocation.
- Discovery: Thor's `ask()` reads piped stdin without a TTY. The PTY driver
  was deleted; the script pipes answers. The TODO's "cannot be tested
  non-interactively" premise was wrong all along.
- Named unknown resolved: the blank path writes `init :"shoreditch"` inside
  `Bridgetown.configure` — clean, parses. `add_gem` against the pre-seeded
  path gem prints its run line, adds no duplicate, and the apply continues.
- Defect found+fixed: quote in an answer wrote unparseable Ruby →
  answers sanitised (`.delete(%(\\")).strip`). Verified: quote-path answer
  `#aa3355"` lands as `accent "#aa3355"` and parses.
- Defect found+fixed: an automation-installed fresh site rendered as the
  starter everywhere — the scaffold's welcome post carries explicit
  `layout: post` (beating `_defaults.yml`) and the starter layouts/stylesheet
  win over the theme. The automation now retires marker-recognisable starter
  files (`Shared::Navbar` in default.erb, the bare `<h1>` scaffolds in
  page/post) and rewrites `layout:` front matter to the shoreditch
  equivalents; edited files are left with a warning.
- Final runs: cached-scaffold run and clean-workdir run both exit 0 — all
  assertions pass on all three paths, index and post both render the
  sidebar, trample gone.
- Docs updated: README install section (what the automation does), CHANGELOG
  Unreleased Fixed (two entries), seed commands table, publish TODO item
  (post-publish `EXERCISE_PRESEED=0` re-run).
- Review (PR #3, two bounded passes) requested changes. Blocker + majors, all
  in the code this branch added, all remediated on-branch:
  - **RCE, and my first fix was wrong.** Sanitising with `.delete(%(\\"))`
    stripped only `"` (the `\` was a `String#delete` escape, not a stripped
    char), so backslashes passed through; and even a correct `.dump` did not
    hold, because **Bridgetown's `add_initializer` insertion rewrites
    backslashes** — it turned the inert `\\\#{` from `.dump` back into a live
    `\\#{`, and `#{Kernel.exit(1)}` executed during the build (proven: the
    `nasty` path's build aborted at Bridgetown startup). Escaping through that
    layer is unreliable. Fixed by **rejecting** answers matching
    `/["\\\r\n]|#[{@$]/` (quote, backslash, newline, or `#{`/`#@`/`#$`
    interpolation) with a warning, so nothing needing escapes is ever written.
  - **Destructive heuristics on a user's files.** `include?(marker)` substring
    tests would delete an edited `default.erb` (still contains `Shared::Navbar`)
    or force-overwrite a customised `index.css` (still contains
    `--body-background`). Replaced with whitespace-normalised **exact match**
    against the embedded pristine scaffold: anything edited is left with a
    note. The gate is strict by design — an unrecognised (newer) scaffold is
    left alone too.
  - **Front-matter rewrite hit body text.** `gsub_file` over the whole file
    rewrote a `layout: post` line inside a fenced code block. Confined to the
    leading `---`…`---` block, and made tolerant of quoted values
    (`layout: "post"`).
  - Script hygiene: `nasty` probe added (quote+backslash+`#{}`), asserting the
    payload never reaches the initializer and the site still builds;
    `EXERCISE_WORKDIR` marker guard refuses to `rm -rf` a dir it did not
    create; no unattended `nvm install`.
- Re-verified: clean-workdir exercise exits 0 on all three paths; a by-hand
  edited-site test confirms edited default.erb and index.css are kept, the
  pristine post.erb is retired, a quoted `layout: "post"` is repointed, and an
  identical line inside a code fence is untouched.
- Remediation re-review (one bounded pass) confirmed all four prior findings
  closed and the rejection regex complete with no bypass, and raised three new
  minor correctness edge cases — all fixed in the same closeout: CRLF front
  matter now repoints (the sub anchored `\r?$` and re-emits the line ending),
  the page glob includes `.markdown`, and a non-UTF-8 source is skipped so the
  pass stays all-or-nothing. Fixes unit-verified (CRLF front matter repointed
  with ending preserved, fence line untouched, invalid encoding guarded) and
  a final full exercise run confirms the happy path.

## Review

**Verdict:** pass — after two remediation rounds on this branch
**Reviewed:** `git diff master...HEAD` — 9 files, ~490 added
**Passes:** standard + security lens, then one remediation re-review (security
lens) after the fixes — three bounded passes, 16/16/4 tool calls
**Criteria:** 7 met (1–6 exercised by `scripts/exercise-automation.sh`,
verified green this session; 7 by inspection)

### Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Living set true of the tree | met | README/CHANGELOG/seed/TODO all updated to the shipped behaviour |
| 2 | Script committed, 3 stdin paths, exits 0 | met | ran it — answered/blank/nasty all pass |
| 3 | Answered path parses + settings + sidebar | met | `accent "#aa3355"` / `logo_legend "TEST"`, post + index carry `sd-sidebar` |
| 4 | Blank path clean init + sidebar | met | bare `init :"shoreditch"`, builds, sidebar present |
| 5 | Hostile answer cannot inject or execute | met | `nasty` path: quote/backslash/`#{…}` answers rejected, no payload in initializer, site builds |
| 6 | Site not trampled by starter stylesheet | met | starter stylesheet cleared on exact match; index + post render the theme |
| 7 | Publish item re-run step; defects fixed/filed | met | `EXERCISE_PRESEED=0` re-run recorded; all defects fixed on-branch |

### Findings — no blockers, no majors open

The first review found a **blocker (RCE)** and majors (destructive file
heuristics, front-matter rewrite hitting body text); all fixed and confirmed
closed by the re-review. The re-review's three new minors (CRLF, `.markdown`,
non-UTF-8) were fixed in the closeout and unit-verified — localized enough
that unit checks plus one full exercise run stand in for a third agent pass.
No finding remains open.

### Retrospective

**Missed:** the implementer's own two escaping fixes were both wrong — the
`.delete` selector semantics, then the assumption that `.dump` survives
Bridgetown's backslash-rewriting insertion. The security-lens pass and the
behavioural `nasty` build-abort caught what inspection had not. The lesson is
recorded in the plan: for generated code behind an insertion layer, reject
unsafe input rather than escape it.
**Owed:** nothing outstanding — all findings fixed on-branch.

## Open questions

- What does `bundle add shoreditch` actually do when the Gemfile already has
  the path-sourced gem — error, no-op, or rewrite? The first run answers
  this; if it aborts the apply, the script works around it and the behaviour
  is recorded here.
