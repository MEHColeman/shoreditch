# Restore what the 1.0.0 rewrite dropped, and fix what hid it

**Status:** in review
**Branch:** `fix-theme-regressions`
**Base:** `master`
**PR:** https://github.com/MEHColeman/shoreditch/pull/2

## Context

The 1.0.0 Bridgetown rewrite dropped features the Jekyll theme had — the
contact panel, comments, per-page sidebar overrides, CV styling — without
recording the loss, and a set of defects (the starter frontend overriding the
theme, the dead `accent` option, the thumbnail column squeeze) hid how the
theme actually rendered. This branch restores the features, fixes the defects,
and reconciles the docs. The criteria below were agreed retroactively with
Mark on 2026-08-08 — the branch predates the plan-doc workflow — derived from
the CHANGELOG "Unreleased" section, which is the branch's documented contract.

## Acceptance criteria

- [x] 1. The production demo build passes the CI smoke checks locally: in
  `demo/` on Node 22, `BRIDGETOWN_ENV=production npm run esbuild && bundle
  exec bridgetown build`; then `output/index.html` and
  `output/shoreditch/shoreditch.css` exist and `sd-sidebar` appears in the
  built index. *(Command-verified.)*
- [x] 2. The demo renders the theme's stylesheet — the built index links the
  theme CSS and the starter frontend no longer overrides it.
  *(Command-verified against the build output.)*
- [x] 3. Every Fixed/Added/Changed entry under CHANGELOG "Unreleased"
  corresponds to code in the diff, and nothing in the diff lands under no
  entry — the changelog and the diff agree in both directions.
  *(Reviewer-checked.)*
- [x] 4. The `accent` option is applied and validated — the configured value
  reaches the page, and a hostile value cannot inject CSS.
  *(Reviewer-checked in `lib/shoreditch.rb` and build output.)*
- [x] 5. Comments stay off when unconfigured — no Giscus script in the built
  demo output. *(Command-verified.)*
- [x] 6. Both colour schemes look right on the index, a post, `/cv/` and a
  tag page. *(User-verified: journal 2026-08-06, re-confirmed by Mark
  2026-08-08. Not verifiable by command.)*
- [x] 7. README documents the shipped behaviour — the restored options,
  `--sd-rule-strong`, the mobile header band, the Node 22 requirement.
  *(Reviewer-checked.)*

## Verification

```sh
cd demo
# Node 22 is required, not advisory: on Node 20 the esbuild step throws while
# the server still serves, so a stale bundle masks CSS changes. .nvmrc pins it.
nvm use
BRIDGETOWN_ENV=production npm run esbuild
BRIDGETOWN_ENV=production bundle exec bridgetown build
test -f output/index.html
test -f output/shoreditch/shoreditch.css
grep -q 'sd-sidebar' output/index.html
grep -q 'shoreditch/shoreditch.css' output/index.html   # theme CSS linked
! grep -qi 'giscus' output/index.html                    # comments stay off
```

## Review

**Verdict:** pass — after one remediation, re-checked inline (docs-only tier)
**Reviewed:** `git diff master...HEAD` — 47 files, +1782 −367
**Passes:** standard + security lens (diff >500 lines), 16 tool calls each
**Criteria:** 7 met (1, 2, 5 command-verified this run; 6 user-verified)

### Acceptance criteria

| # | Criterion | Verdict | Evidence |
|---|---|---|---|
| 1 | Build + smoke checks | met | ran it: esbuild + `bridgetown build` clean on Node 22.23.2, all three smoke greps pass |
| 2 | Theme stylesheet wins | met | starter layouts deleted; `frontend/styles/index.css` now a stub (67B built); theme CSS linked |
| 3 | CHANGELOG ↔ diff, both ways | met after fix | all 20 entries map to code; `.sd-archive` had no entry — added, re-checked inline |
| 4 | Accent applied + validated | met | anchored regex excludes every metacharacter; invalid → default; HTML-escaped at emission |
| 5 | Comments off unconfigured | met | `render?` needs all four keys; no giscus in built output |
| 6 | Both schemes, four pages | met | user-verified (journal 2026-08-06, re-confirmed 2026-08-08); 16 tokens identical membership in all four blocks |
| 7 | README documents behaviour | met | override table, `--sd-rule-strong`, mobile band, Node 22 all present |

### Findings — no blockers, no majors

- Minor: excerpt regex breaks on blockquote/code-fence openings → TODO item.
- Minor: `data-network="twitter"` vs CSS `"x"`; verbatim mastodon/youtube
  hrefs admit `javascript:` (self-XSS) → folded into contact-fields TODO item.
- Minor: orphaned demo starter files survived the layout deletion → TODO item.
- Nits (recorded here only): 5/7-digit hex passes accent validation but is
  invalid CSS; Giscus is the sole external request — README could say so
  explicitly; an author with only `name` renders an empty `.sd-details` list.

### Retrospective

**Missed:** changelog completeness was checked forward only during the work;
the reverse direction (diff → changelog) caught `.sd-archive` in review.
**Owed:** 2 new items + 1 update captured in docs/TODO.md.
