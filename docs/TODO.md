# shoreditch — tasks

Task list for **shoreditch**, maintained by agents and inbox triage. Standard
Obsidian checkboxes: `- [ ]` open, `- [x]` done.

## Inbox

- [ ] Publish 1.1.0 to RubyGems
    - Why: `MEHColeman/blog` currently depends on this theme through a git
      source, which pins a revision and clones on every deploy. A released gem
      makes `bundle add shoreditch` work for anyone, which is the whole point
      of the rewrite.
    - Known: sign-off given 2026-08-08. Decisions: first published version is
      **1.1.0** (Unreleased rolled in; 1.0.0 stays git-only so nobody installs
      the known-defective release), publish route is a **local `gem push`**
      (trusted publishing via CI deliberately deferred), Mark's rubygems.org
      account exists with MFA on.
    - Known: the name `shoreditch` was free on rubygems.org as of 2026-08-08
      (`GET /api/v1/gems/shoreditch.json` → 404).
    - Known: staging exposed the gemspec shipping dev files — the exclusion
      regex said `script/` (singular) so `scripts/exercise-automation.sh` was
      in the gem, and `docs/`, `.github/`, `.gitignore` shipped too. Fixed,
      along with bounding the bridgetown dependency to `~> 2.0` (the theme is
      written against Bridgetown 2's APIs). `shoreditch-1.1.0.gem` built and
      its contents verified clean.
    - Plan: (1) Mark: `gem signin` with an API key scoped to push_rubygem
      only. (2) Commit the staged release (version bump, changelog roll,
      gemspec fixes) to master, tag `v1.1.0`, push both. (3) `gem push
      shoreditch-1.1.0.gem` — if the account's MFA level is "UI and API",
      Mark runs it himself to type the OTP. (4) Verify on rubygems.org.
      (5) Re-run `EXERCISE_PRESEED=0 scripts/exercise-automation.sh` — the
      automation's `add_gem "shoreditch"` route has only ever been tested
      with a pre-seeded path-sourced Gemfile (see docs/acceptance.md).
      (6) Update seed/TODO/journal; the blog's Gemfile switch to
      `gem "shoreditch", "~> 1.1"` happens in that repo.
    - Done when: the blog's Gemfile can say `gem "shoreditch", "~> 1.1"`, and
      the no-pre-seed exercise run passes.

- [ ] Configure Giscus on the demo, or decide not to
    - Why: the comments component is implemented and verified to stay off when
      unconfigured, but has never rendered a real thread — the four Giscus IDs
      need Discussions enabled on the repo and a pass through giscus.app.
    - Files: `components/shoreditch/comments.rb`, `demo/config/initializers.rb`
    - Known: `render?` requires all four of repo / repo_id / category /
      category_id, treating a partial config as off, because Giscus otherwise
      renders nothing and gives no clue why.
    - Done when: either a thread renders on the demo and follows the theme
      toggle, or a decision is recorded that the demo does not want comments.

- [ ] Resolve the dead `.sd-table-wrap` rule
    - Why: `content/shoreditch/shoreditch.css:745` styles
      `.sd-content .sd-table-wrap { overflow-x: auto }`, but nothing in
      `layouts/` or `components/` ever emits that wrapper —
      `grep -rn 'sd-table-wrap' content/ layouts/ components/` returns only the
      CSS. So a wide table in a post overflows the content column instead of
      scrolling inside it.
    - Files: `content/shoreditch/shoreditch.css`
    - Known: the demo's "Example Content" post has a three-row table, but it is
      `width: 100%` and narrow enough to fit, so nothing looks wrong today. A
      table with many columns would break the page.
    - Approach: either emit the wrapper (kramdown does not do this by itself —
      it needs a builder or a post-render hook) or delete the rule and let
      tables be the site's problem. Deleting is honest; emitting is kinder.
      Decide which, do not leave it dead.
    - Done when: a wide table either scrolls inside its own container, or the
      rule is gone and the README says tables are the site's responsibility.

- [ ] Make the contact fields consistent about handles vs URLs
    - Why: `components/shoreditch/details.rb` ENTRIES takes a bare handle for
      most networks (`github: yourhandle` → `https://github.com/%s`) but a full
      URL for `mastodon` and `youtube`, whose templates are just `"%s"`. Nothing
      signals which is which except the README comments, so getting it wrong
      produces a broken link with no error.
    - Files: `components/shoreditch/details.rb`, `README.md`
    - Known: Mastodon genuinely cannot take a bare handle — the instance is
      part of the address — so full-URL is right there. YouTube has no single
      canonical handle form either (`@handle`, `/c/`, `/channel/`). The
      inconsistency is defensible; the silence about it is not.
    - Known: the 2026-08-08 review's security pass added weight — the
      `mastodon`/`youtube` values are emitted verbatim into `href`, so a
      `javascript:` value in site metadata renders a clickable script link
      (self-XSS only, it is the owner's own config, but inconsistent with the
      validation standard `accent` sets). A `https?://` scheme check with
      drop-on-fail, mirroring `css_colour`, closes it.
    - Known: same review, cosmetic — ENTRIES emits `data-network="twitter"`
      but the CSS brand-hover rule styles only `[data-network="x"]`
      (`shoreditch.css` ~362), so a twitter handle gets no hover glow and the
      `x` rule is dead. Fix whichever side is wrong while in the file.
    - Approach: either accept both forms per field (pass anything starting
      `http` through untouched, otherwise interpolate) which makes the whole
      list forgiving, or leave the behaviour and make the README table explicit
      about which fields want a URL. Add the scheme check either way.
    - Done when: entering a full URL in a handle field, or a handle in a URL
      field, either works or is documented clearly enough not to happen; a
      non-http(s) scheme is dropped.

- [ ] Fix index excerpt extraction for posts opening with a blockquote or code fence
    - Why: `components/shoreditch/post_summary.rb` (~20–36) cuts the rendered
      post at the first `</p>` (or `<!--more-->`) and marks it `html_safe`. A
      post opening with a blockquote stops at the *inner* `</p>`, emitting an
      unclosed `<blockquote>` into the index — browsers recover at the
      wrapping div and the flatten rule hides it visually, but the HTML is
      invalid, and the CHANGELOG claims this case handled. A post opening with
      a fenced code block has no `</p>` inside the Rouge output, so the
      excerpt swallows the whole highlighted block plus the following
      paragraph.
    - Files: `components/shoreditch/post_summary.rb`
    - Known: found by the 2026-08-08 review of `fix-theme-regressions`
      (minor, both passes flagged it). The `{:.message}` case is fine — that
      is a single paragraph carrying a class, so it ends at its own `</p>`;
      nesting is what breaks.
    - Approach: take the first *top-level* block instead of the first `</p>`
      — Nokogiri is already in Bridgetown's dependency tree, so the first
      child element's `to_html` does it; keep `<!--more-->` honoured first.
    - Done when: a post opening with a blockquote yields balanced excerpt
      HTML and one opening with a code fence yields only that block, both
      verified in the built index.

- [ ] Delete the orphaned demo starter files
    - Why: the demo layouts that rendered them were deleted when the demo
      moved onto the theme's layouts, but
      `demo/src/_components/shared/navbar.{erb,rb}` and
      `demo/src/_partials/{_head,_footer}.erb` remain, referenced by nothing.
    - Known: found by the 2026-08-08 review (minor). The deleted demo layouts
      were the only callers.
    - Done when: the files are gone and the demo builds clean.

- [ ] Tidy the "What's Bridgetown?" demo post
    - Why: it says "is an alternative _Jamstack_ alternative to Jekyll" and then
      "created an excellent alternative" two lines later — three uses of the
      word in three lines, one of them a duplication.
    - Files: `demo/src/_posts/2021-10-15-whats-bridgetown.md` lines 10–12
    - Known: pre-existing copy, carried over rather than introduced. Noticed
      because the excerpt fix made the first sentence visible on the home page
      for the first time.
    - Done when: the sentence reads cleanly on the index and in the post.

- [ ] Rebuild the CV highlight filter, if wanted
    - Why: 0.9.0 had a checkbox toggling a `highlight` body class, lighting up
      links from the CV to related blog posts. Deliberately left out of the
      restoration on 6 Aug 2026 — the original used an inline `onclick` and a
      global function, so it wants rebuilding rather than porting.
    - Known: the `.cv` styling and every per-page sidebar override it depended
      on are already in place, so this is self-contained.

- [ ] Add a screenshot to the README
    - Why: the README lost its screenshots when the Jekyll `public/images/`
      tree was deleted — they showed the old design and would now be
      misleading. A theme README without a picture of the theme is a poor
      advertisement.
    - Approach: take one from the demo site once it is deployed.

- [ ] Consider a test suite
    - Why: `bridgetown plugins new` scaffolds `test/` with fixtures and a
      helper, and none of that was carried over. The components have real
      logic worth testing — `HeadIcons` decides which icons exist, `Sidebar`
      filters and sorts nav pages.
    - Known: the demo build in CI is currently the only check, and it only
      asserts that an index page, the stylesheet and a sidebar exist.

- [ ] Decide about `logo_link`
    - Why: `Sidebar` reads `site.metadata.logo_link` but the README documents
      it only in passing, and there is no theme option for it. It is
      inconsistent with the other logo settings, which are initializer
      options.

- [ ] Decide whether the CV's contact panel should compact on phones
    - Why: the mobile header band is 137px on every page except the CV, where
      it is 343px. The contact panel is nine stacked rows, and on a CV
      `include_sticky: false` drops the site title and nav, so the band is
      logo + name badge + those nine rows.
    - Known: measured 2026-08-07 at 390×844 with the theme's own tooling. It is
      not obviously wrong — on a CV the contact details arguably *are* the
      header, and the CV has no cover image, so the page title still lands at
      43% of the first screen, better than a post's 45%. This is a judgement
      call, not a defect, which is why it was left alone.
    - Approach: if it should compact, make `.sd-details` a wrapped horizontal
      row inside the mobile band (it is already a flex column, so it is a
      `flex-direction` and `gap` change in the existing
      `@media (max-width: 59.99rem)` block). Weigh against scannability —
      a vertical list of contact methods is the conventional CV treatment.
    - Done when: either the row treatment is in and checked on `/cv/` at
      390px, or this is closed as deliberate and the reasoning recorded.

## Doing

## Done

- [x] Exercise `bridgetown.automation.rb` against a fresh site — PR #3, merged
      2026-08-08. The install route had never run; `scripts/exercise-automation.sh`
      now drives it against a fresh site (answered / blank / hostile-answer
      paths). The exercise surfaced defects the branch then fixed: an
      automation-installed site rendered as the starter, not the theme; and a
      prompt answer could execute as code at site load (an RCE the review's
      security pass caught, and two escaping attempts failed to close before
      rejection did). See `docs/acceptance.md`; review in git history
      (`git log -- docs/tasks/bridgetown-automation.md`).
- [x] Rebuild as a gem-based Bridgetown plugin with a source manifest
- [x] Redesign in modern CSS with light/dark and a toggle
- [x] Add `bridgetown.automation.rb` for one-step install
- [x] Finish the flexbox sidebar abandoned in the Jekyll version
- [x] Add the `demo/` site
- [x] Enable GitHub Pages with GitHub Actions as the source — the demo deploys
      green (though it has no reachable URL until DNS lands; see Inbox)
- [x] Stop the demo's starter stylesheet overriding the theme — it had been
      pulling `.sd-main` out of the two-column grid since the rewrite, so the
      demo had never once displayed the theme as designed
- [x] Wire the `accent` option through to CSS — it had never had any effect
- [x] Restore cover banners and flush-left thumbnails from front matter
- [x] Restore the mural logo, resized for web (27MB of PNG → 1.4MB of JPEG)
- [x] Restore the contact panel, per-page sidebar overrides and CV styling
- [x] Replace Disqus with a pluggable comments slot, shipping Giscus
- [x] Give the theme its own light/dark syntax palette
- [x] Verify light mode — checked on the index, a post, the CV page and a tag
      page. The light Rouge palette, the half that had never been seen, is
      legible. Headless Chrome cannot be made to request light by CLI flag on
      this machine; `Emulation.setEmulatedMedia` over the DevTools protocol is
      what works
- [x] Reframe index entries — the hairline-rule listing left the stack with no
      shared left edge, because a post without a thumbnail began its title
      where its neighbours began an image column
- [x] Review and merge `fix-theme-regressions` — PR #2, merged 2026-08-08.
      7/7 criteria met after one remediation (the reverse changelog check
      caught `.sd-archive` under no entry). Verified criteria are in
      `docs/acceptance.md`; the review itself is in git history
      (`git log -- docs/tasks/fix-theme-regressions.md`)
- [x] Create the DNS record for the demo's custom domain — Mark added the
      DNSimple CNAME 2026-08-08; certificate provisioning had stalled (the
      domain predated the record) and needed the domain removed and re-added
      via the Pages API, after which Let's Encrypt issued in ~4 minutes.
      "Enforce HTTPS" is on: <https://shoreditch.mehcoleman.com/> serves over
      HTTP/2 and plain HTTP 301s to it. The github.io URL 301s there too, as
      expected
