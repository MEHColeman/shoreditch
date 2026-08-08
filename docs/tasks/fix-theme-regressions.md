# Restore what the 1.0.0 rewrite dropped, and fix what hid it

**Status:** in review
**Branch:** `fix-theme-regressions`
**Base:** `master`
**PR:**

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

- [ ] 1. The production demo build passes the CI smoke checks locally: in
  `demo/` on Node 22, `BRIDGETOWN_ENV=production npm run esbuild && bundle
  exec bridgetown build`; then `output/index.html` and
  `output/shoreditch/shoreditch.css` exist and `sd-sidebar` appears in the
  built index. *(Command-verified.)*
- [ ] 2. The demo renders the theme's stylesheet — the built index links the
  theme CSS and the starter frontend no longer overrides it.
  *(Command-verified against the build output.)*
- [ ] 3. Every Fixed/Added/Changed entry under CHANGELOG "Unreleased"
  corresponds to code in the diff, and nothing in the diff lands under no
  entry — the changelog and the diff agree in both directions.
  *(Reviewer-checked.)*
- [ ] 4. The `accent` option is applied and validated — the configured value
  reaches the page, and a hostile value cannot inject CSS.
  *(Reviewer-checked in `lib/shoreditch.rb` and build output.)*
- [ ] 5. Comments stay off when unconfigured — no Giscus script in the built
  demo output. *(Command-verified.)*
- [ ] 6. Both colour schemes look right on the index, a post, `/cv/` and a
  tag page. *(User-verified: journal 2026-08-06, re-confirmed by Mark
  2026-08-08. Not verifiable by command.)*
- [ ] 7. README documents the shipped behaviour — the restored options,
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
