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

## Install automation exercised and hardened (`bridgetown-automation`, PR #3, 2026-08-08)

- `bin/bridgetown apply` installs the theme end to end on a fresh site:
  `scripts/exercise-automation.sh` scaffolds a site, installs the gem either
  pre-seeded as a path source or straight from RubyGems (`EXERCISE_PRESEED=0`),
  and drives the apply with answers piped on stdin for three paths — both
  prompts answered, both blank, and a hostile answer — asserting the
  initializer parses, the site builds, and both the index and a post render
  `sd-sidebar`.
- An automation-installed site renders as the theme. The automation retires a
  starter layout or stylesheet only when it is exactly the untouched
  `bridgetown new` scaffold (whitespace aside), and repoints the pages that
  named a retired layout by editing only their front matter — never a
  `layout:` line in body text or a code fence. A file the site has edited is
  left in place with a note.
- A prompt answer cannot inject code. Answers carrying a quote, a backslash, a
  newline, or a Ruby interpolation (`#{`, `#@`, `#$`) are rejected rather than
  escaped — escaping is unreliable because Bridgetown's `add_initializer`
  insertion rewrites backslashes, which reactivated an escaped `#{` in
  testing and executed it at site load. A rejected answer is dropped with a
  note to set that option by hand.
- The pure `bundle add shoreditch` install route is proven: with shoreditch
  1.1.0 live on RubyGems, the `EXERCISE_PRESEED=0` run passed all three answer
  paths against the real registry (2026-08-08).
