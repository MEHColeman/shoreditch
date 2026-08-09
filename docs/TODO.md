# shoreditch — tasks

Task list for **shoreditch**, maintained by agents and inbox triage. Standard
Obsidian checkboxes: `- [ ]` open, `- [x]` done.

## Inbox

- [ ] Consider Trusted Publishing via GitHub Actions for future releases
    - Why: deliberately deferred at the 1.1.0 publish in favour of a local
      `gem push`. OIDC-based publishing needs no long-lived API key and makes
      releases reproducible from a tag push.
    - Known: the account's API key requires an OTP per push, so every local
      release needs Mark at a real terminal (the in-session runner has no
      interactive stdin — discovered 2026-08-08). Trusted publishing removes
      that step. Register the publisher under the gem's settings on
      rubygems.org, add a release workflow triggered on tag push.

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

- [ ] Expand the test suite beyond the excerpt cases
    - Why: the scaffold exists as of 2026-08-09 (`Rakefile`, `test/`,
      minitest via `bundle exec rake test` — seeded on
      [[index-excerpt-extraction]] with eight excerpt cases), but the
      components still have untested logic — `HeadIcons` decides which icons
      exist, `Sidebar` filters and sorts nav pages.
    - Known: component tests need more scaffolding than the pure-logic
      excerpt tests did — `Bridgetown::Component` subclasses want a site and
      render context, where `Shoreditch::Excerpt` loads with plain kramdown.
    - Known: the demo build in CI is otherwise the only check, and it only
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

- [x] Fix index excerpt extraction for posts opening with a blockquote or code
      fence — fixed 2026-08-09 on `fix/index-excerpt-extraction` (plan
      [[index-excerpt-extraction]]). Extraction moved to
      `lib/shoreditch/excerpt.rb`: `<!--more-->` wins (now balanced even
      mid-paragraph), else the first top-level prose block, so a code-fence
      opener excerpts its first *paragraph* (amended done-when, decided in
      session). Parsed with kramdown's own HTML parser — the plan's belief
      that Nokogiri was already in Bridgetown's tree turned out false, so
      Nokogiri was dropped rather than added as a dep. Verified in the built
      index via two new demo fixture posts.
- [x] Delete the orphaned demo starter files — deleted 2026-08-09 on the same
      branch (`demo/src/_components/shared/navbar.{erb,rb}`,
      `demo/src/_partials/{_head,_footer}.erb`); demo builds clean without
      them.
- [x] Tidy the "What's Bridgetown?" demo post — rewritten 2026-08-09 on the
      same branch; one "alternative" in the opening paragraph, verified in the
      built post and index.

- [x] Switch `MEHColeman/blog` to `gem "shoreditch", "~> 1.1"` — Mark made
      the change 2026-08-09. At the time of recording it was local to his
      working copy (the blog repo's last push predates the gem), so the
      deployed blog picks it up on his next push there.
- [x] Publish to RubyGems — **1.1.0 live 2026-08-08**, the first published
      version (1.0.0 stays git-only so the registry never serves the
      known-defective release). Name availability checked first; staging
      caught the gemspec shipping `scripts/`, `docs/` and `.github/` (the
      exclusion regex said `script/`, singular) and the open-ended bridgetown
      dependency, both fixed before the push. Tagged `1.1.0` on master
      (`5d436ec`). The pure `bundle add shoreditch` route then proven by
      `EXERCISE_PRESEED=0 scripts/exercise-automation.sh` — all three answer
      paths passed against the live registry (see docs/acceptance.md). The
      blog's Gemfile switch is a new Inbox item.
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
