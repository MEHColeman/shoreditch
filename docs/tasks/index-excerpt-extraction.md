# Index excerpt extraction for non-prose openings

**Status:** in progress
**Branch:** fix/index-excerpt-extraction
**Worktree:** ../shoreditch-worktrees/index-excerpt-extraction
**Base:** master
**PR:** https://github.com/MEHColeman/shoreditch/pull/5
**Issue:** none
**Todo:** "Fix index excerpt extraction for posts opening with a blockquote or code fence" in docs/TODO.md (plus two ride-alongs, see Context)
**Planned at:** 48bc6ce0b07c27b1238c143b1985623891274060

## Context

The 1.1.0 changelog claims index excerpts are handled "whatever block the post
opens with", and for two openers that claim is false. A post opening with a
blockquote emits an unclosed `<blockquote>` into the index (browsers recover,
the flatten rule hides it visually, but the HTML is invalid). A post opening
with a fenced code block has no `</p>` inside the Rouge output, so the excerpt
swallows the entire highlighted block plus the following paragraph. Found by
the 2026-08-08 review of `fix-theme-regressions` (both passes flagged it);
fixing it is the first entry toward the accumulating 1.1.1 patch release.

Mark's decisions (2026-08-09, in session):

- **Skip non-prose blocks**: a code-fence-opening post excerpts its first
  *paragraph*, not the code block — a code dump is a poor preview. This
  **amends the TODO item's recorded done-when**, which said the excerpt is
  "only that block".
- **Seed the test suite here** (minitest + rake) — the extraction logic is
  exactly the pure logic worth unit-testing, and "Consider a test suite" has
  been an open item since the rewrite.
- **Two demo-only ride-alongs** on this branch: delete the orphaned starter
  files, and tidy the triple-"alternative" copy in the "What's Bridgetown?"
  post.
- **No immediate release**: the fix accumulates under Unreleased toward 1.1.1.

No docs/goals.md exists in this project; no goal ID to cite.

## What's already known

- The logic is `Shoreditch::PostSummary#summary` in
  `components/shoreditch/post_summary.rb` (~26–37): honour `<!--more-->`
  (everything before the marker), else `html[%r{\A.*?</p>}m]` — cut the
  rendered HTML at the first `</p>` anywhere — else the whole content; result
  marked `html_safe`. The template wraps it in `<div class="sd-post-excerpt">`
  (`components/shoreditch/post_summary.erb`).
- "Set as plain text" is CSS, not extraction: `shoreditch.css` ~647–668
  flattens `:is(p, blockquote, .message, .callout, .alert, .alarm)` inside
  `.sd-post-excerpt` and line-clamps to three lines. A `p`-or-`blockquote`
  excerpt is therefore already covered by the flatten rule — skipping
  non-prose blocks means **no CSS change is needed**.
- The blockquote failure is the *inner* `</p>`: kramdown renders
  `<blockquote><p>…</p></blockquote>`, so the cut lands inside. The
  `{:.message}` case is fine — a single `<p class="message">` ends at its own
  `</p>`.
- Rouge output for a fenced block is `<div class="highlight"><pre
  class="highlight"><code>…` — no `</p>` at all, hence the swallow.
- **The plan's Nokogiri premise was false**: Bridgetown 2.2.2 ships no HTML
  parser gem at all — `grep nokogiri demo/Gemfile.lock` is empty and
  `bundle exec ruby -e 'require "nokogiri"'` fails in the demo bundle
  (verified at pickup, 2026-08-09). Parsing is done with **kramdown's own
  HTML parser** instead (`Kramdown::Document.new(html, input: "html")`) —
  kramdown rendered the HTML being parsed, so it is definitionally present
  and the "no new runtime dep" premise stays true by a different route.
- Kramdown roundtrip behaviour, prototyped before committing: blockquote
  openers come back balanced, `class="message"` survives, a marker cut
  mid-paragraph re-renders with closed tags. One trade-off: in the no-prose
  fallback, Rouge's `<span>` markup inside `<pre><code>` is re-parsed as text
  and stripped — structure balanced, highlighting lost, degenerate case only.
- The gemspec already excludes `test/` from the gem (exclusion regex updated
  2026-08-08), and carries `rake` as a development dependency; minitest needs
  adding.
- Component `.erb` sidecars are cached — demo server restart needed after
  editing them; `bin/bridgetown build` is the honest check.
- Demo builds need Node 22 (`demo/.nvmrc`); on Node 20 the frontend build
  fails silently while the site still serves.
- Orphaned demo files (referenced by nothing since the demo moved onto the
  theme's layouts): `demo/src/_components/shared/navbar.{erb,rb}`,
  `demo/src/_partials/_head.erb`, `demo/src/_partials/_footer.erb`.
- Demo copy defect: `demo/src/_posts/2021-10-15-whats-bridgetown.md` lines
  10–12 — "is an alternative _Jamstack_ alternative to Jekyll" plus a third
  "alternative" two lines later.
- README documents neither `<!--more-->` nor the excerpt rule at all
  (`grep -n "more\|excerpt" README.md` prints nothing) — user-facing
  behaviour, currently undocumented.
- Demo content is placeholder only — no real contact details; new demo posts
  must follow that.

## Registry delta

This project's living set (no docs/system/ split here):

- `README.md` — gains a short note on index excerpts: first paragraph wins,
  `<!--more-->` overrides, non-prose openers are skipped.
- `CHANGELOG.md` — new Unreleased section: Fixed (excerpt extraction for
  blockquote/code-fence openers, correcting 1.1.0's overbroad claim), Added
  (the test suite).
- `docs/seed.md` — layout map gains `lib/shoreditch/excerpt.rb`, `test/`,
  `Rakefile`; commands table gains `bundle exec rake test`.
- `docs/TODO.md` — the excerpt item and both ride-alongs move to Done;
  "Consider a test suite" narrows to expanding coverage (scaffold exists).
- `docs/acceptance.md` — verified criteria distilled at closeout by
  review-merge.
- `docs/journal.md` — session entry at close.

## Approach

1. Extract the logic into `Shoreditch::Excerpt.extract(html)` — new
   `lib/shoreditch/excerpt.rb`, required from `lib/shoreditch.rb`. Behaviour:
   `<!--more-->` first — everything before the marker, now re-rendered so a
   mid-block marker yields closed tags (content unchanged, validity gained);
   otherwise parse with kramdown's HTML parser (**not Nokogiri — see Known**)
   and return the first top-level `p` or `blockquote` element, re-rendered;
   if no such element exists, fall back to the first top-level block
   (balanced, unlike today); empty/nil content returns `""`.
2. `PostSummary#summary` delegates to it, keeping `html_safe` (the input is
   kramdown's rendered output, same trust level as today).
3. Test scaffold: `Rakefile` with `rake test` as default task,
   `test/test_helper.rb`, `test/test_excerpt.rb`; `minitest` added to the
   gemspec's development dependencies. Cases: plain paragraph; hard-wrapped
   paragraph; blockquote opener (balanced output); realistic Rouge code-fence
   opener (yields the following paragraph); `<!--more-->` wins; `{:.message}`
   paragraph; no-prose-block fallback; empty content.
4. Demo: add two short placeholder posts, one opening with a blockquote and
   one with a fenced code block — they prove the fix in the built index and
   double as demonstration content. Verify `demo/output/index.html`.
5. Ride-alongs: delete the four orphaned demo starter files; fix the
   "What's Bridgetown?" sentence.
6. Docs per the registry delta.

## Acceptance criteria

- [x] The living set is true of the tree again: every document named in the registry delta is updated on this branch, and the ones named unchanged still read true
- [x] In the built demo index, the blockquote-opening post's `.sd-post-excerpt` contains a balanced `<blockquote>` (equal open/close tags within the excerpt div)
- [x] In the built demo index, the code-fence-opening post's `.sd-post-excerpt` contains its first paragraph and no `highlight`/`<pre>` markup
- [x] `bundle exec rake test` exits 0, covering all eight cases named in the approach
- [x] `git ls-files demo/src/_components/shared demo/src/_partials` prints nothing, and the demo builds clean without the deleted files
- [x] The "What's Bridgetown?" post uses "alternative" at most once in its opening paragraph, in the built post and index
- [x] CHANGELOG.md's Unreleased section records the fix and the test suite

## Verification

```
bundle exec rake test                       # exits 0, 8+ assertions
cd demo && bin/bridgetown build             # clean build, Node 22
# balanced blockquote + no highlight markup in the two new posts' excerpts:
ruby -r nokogiri -e 'doc = Nokogiri::HTML(File.read("output/index.html"));
  doc.css(".sd-post-excerpt").each { |e| puts e.to_html }'  # inspect by eye
git ls-files demo/src/_components/shared demo/src/_partials  # empty
grep -c alternative demo/src/_posts/2021-10-15-whats-bridgetown.md  # ≤1 in the opening
```

## Progress log

- Planned 2026-08-09; decisions recorded in Context. Not started.
- Picked up 2026-08-09. Freshness check reported drift on docs/TODO.md; the
  two new commits were the plan's own landing (PR #4), so no claims changed —
  Planned at refreshed to 48bc6ce. Worktree created at
  ../shoreditch-worktrees/index-excerpt-extraction on fix/index-excerpt-extraction.
- **Material drift found and resolved at implementation**: the Nokogiri
  premise was false (no HTML parser gem anywhere in Bridgetown 2.2.2's tree).
  Switched the mechanism to kramdown's HTML parser after prototyping all four
  shapes in the demo bundle — same behaviour, zero new runtime deps. Recorded
  in Known/Approach above; surfaced to Mark in session.
- Implemented: `lib/shoreditch/excerpt.rb` + delegation from `PostSummary`;
  Rakefile + `test/` scaffold (8 cases, all passing — one assertion loosened:
  the roundtrip normalises a hard-wrap newline to a space, content intact);
  minitest added as dev dependency; two demo fixture posts; four orphaned
  demo files deleted; "What's Bridgetown?" sentence fixed (one "alternative",
  in source, built post and index); README §Index excerpts + §Development,
  CHANGELOG Unreleased, seed.md layout/commands updated.
- Verified in the built index (Node 22 via nvm, frontend rebuilt): blockquote
  excerpt balanced; code-fence post excerpts its paragraph with no
  `highlight`/`<pre>`; both `<!--more-->` posts now close their `<p>` —
  previously unbalanced; `{:.message}` keeps its class.

## Review

**Verdict:** pass — after one remediation, re-reviewed
**Reviewed:** `git diff master...fix/index-excerpt-extraction` — 20 files, +377 −112; one blind pass (15 of ≤25 calls) + one re-review pass (2 calls)
**Criteria:** 7 met (1 after remediation `e5fc930`)

### Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Living docs true of tree | met | after `e5fc930` the gemspec no longer ships the Rakefile; seed.md's exclusion line reads true |
| 2 | Blockquote excerpt balanced | met | built index: 1 open / 1 close inside `.sd-post-excerpt` |
| 3 | Code-fence excerpt = first paragraph | met | excerpt is the `<p>` only; no `highlight`, no `<pre` |
| 4 | `rake test` green, eight cases | met | 8 runs, 38 assertions, 0 failures — session and reviewer both ran it |
| 5 | Orphans gone, demo builds clean | met | `git ls-files` on both paths empty; rebuild exit 0 |
| 6 | "alternative" at most once | met | 1 in source, 1 in built post, 1 in built index |
| 7 | CHANGELOG Unreleased records both | met | Fixed (extraction) + Added (test suite) present |

### Findings

**Minor — `shoreditch.gemspec:31`** — the reject regex kept `test/` out of the
gem but shipped the top-level `Rakefile`, while the new seed.md line claimed
both excluded. Fixed in `e5fc930`; re-review confirms nothing leaks and the
gem keeps everything it needs. No other findings — the reviewer's adversarial
probes of `Shoreditch::Excerpt.extract` (raw-HTML/table/script openers,
escaped marker in `<code>`, comment-only content, marker at position 0) all
behaved sensibly. PR #5 body graded against the description standard: clean
(tickets and CVEs n/a).

### Retrospective

**Missed:** adding top-level files (Rakefile, test/) without re-checking the
gemspec's exclusion regex — a new top-level file needs a gem-contents check.

## Open questions

- None — the code-excerpt fork, test seeding, ride-along scope and release
  timing were all decided in session (see Context).
