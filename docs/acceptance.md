# Acceptance record

Present-tense facts proven at merge time. Each section names the branch and
PR that proved them; the full reviews live in git history under
`docs/tasks/`.

## Theme regressions fixed (`fix-theme-regressions`, PR #2, 2026-08-08)

- The production demo build passes the CI smoke checks: esbuild and
  `bridgetown build` run clean on Node 22, `output/index.html` and
  `output/shoreditch/shoreditch.css` exist, and `sd-sidebar` appears in the
  built index.
- The demo renders the theme's own stylesheet. The starter frontend is an
  empty stub (67 bytes built) and overrides nothing.
- The CHANGELOG "Unreleased" section and the branch's diff agree in both
  directions — every entry maps to code, every change has an entry.
- The `accent` option reaches the page and is validated: the regex is fully
  anchored, every branch excludes the characters that could close the
  declaration or the `<style>` element, invalid values fall back to the
  default, and the emitted value is HTML-escaped. A hostile config value
  cannot inject CSS.
- Comments stay off unless all four Giscus keys are configured; the built
  demo output carries no Giscus script.
- Light and dark both render correctly on the index, a post, `/cv/` and a
  tag page — user-verified, including the light Rouge palette.
- The README documents the shipped behaviour: the per-page sidebar
  overrides, `--sd-rule-strong`, the compact mobile header band, and the
  Node 22 requirement.
- No unescaped ERB output exists in components, layouts, or the demo; the
  first-paint theme script whitelists its localStorage value; the vendored
  icons are plain path data (CC0, attributed); the theme makes no external
  network request except opt-in Giscus.
