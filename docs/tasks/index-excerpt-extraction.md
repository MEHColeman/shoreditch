# Index excerpt extraction for non-prose openings

**Status:** queued
**Branch:** none yet — fix/index-excerpt-extraction at pickup
**Base:** master
**PR:** none yet
**Issue:** none
**Todo:** "Fix index excerpt extraction for posts opening with a blockquote or code fence" in docs/TODO.md (plus two ride-alongs, see Context)
**Planned at:** 9a893dacddcf762ffe6691ec4db89747fc3ff719

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
- Nokogiri is already in Bridgetown's dependency tree — no new runtime dep.
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
   `<!--more-->` first (everything before the marker, unchanged semantics);
   otherwise parse with `Nokogiri::HTML5.fragment` and return `to_html` of the
   first top-level `p` or `blockquote` element; if no such element exists,
   fall back to the first top-level element's `to_html` (balanced, unlike
   today); empty/nil content returns `""`.
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

- [ ] The living set is true of the tree again: every document named in the registry delta is updated on this branch, and the ones named unchanged still read true
- [ ] In the built demo index, the blockquote-opening post's `.sd-post-excerpt` contains a balanced `<blockquote>` (equal open/close tags within the excerpt div)
- [ ] In the built demo index, the code-fence-opening post's `.sd-post-excerpt` contains its first paragraph and no `highlight`/`<pre>` markup
- [ ] `bundle exec rake test` exits 0, covering all eight cases named in the approach
- [ ] `git ls-files demo/src/_components/shared demo/src/_partials` prints nothing, and the demo builds clean without the deleted files
- [ ] The "What's Bridgetown?" post uses "alternative" at most once in its opening paragraph, in the built post and index
- [ ] CHANGELOG.md's Unreleased section records the fix and the test suite

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

## Review

<Written by review-merge.>

## Open questions

- None — the code-excerpt fork, test seeding, ride-along scope and release
  timing were all decided in session (see Context).
