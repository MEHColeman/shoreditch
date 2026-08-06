# shoreditch — tasks

Task list for **shoreditch**, maintained by agents and inbox triage. Standard
Obsidian checkboxes: `- [ ]` open, `- [x]` done.

## Inbox

- [ ] Create the DNS record for the demo's custom domain
    - Why: Pages is enabled, the workflow deploys green, and the custom domain
      is set to `shoreditch.mehcoleman.com` — but that name has no DNS record,
      so the site 301s to a host that does not resolve.
    - Known: there is **no working fallback URL**. Setting the custom domain in
      repo settings also makes GitHub 301 `mehcoleman.github.io/shoreditch/` to
      the non-resolving name, so the demo is unreachable at every public URL
      until this lands. (An earlier note here claimed the github.io URL still
      worked; verified 6 Aug 2026 that it does not.) Removing the custom domain
      from repo settings restores it within about a minute, if a working link
      is needed before DNS propagates.
    - Known: `dig` is not installed on this machine; `resolvectl query
      shoreditch.mehcoleman.com` is the local check. It currently returns no
      record at all — neither A nor AAAA.
    - Known: do not touch the apex. `mehcoleman.com` and `www` both resolve to
      157.245.31.183 and are in use by something else.
    - Approach: at **DNSimple**, add
      `shoreditch.mehcoleman.com  CNAME  mehcoleman.github.io`.
      Then turn on "Enforce HTTPS" in Settings → Pages — the API refuses it
      until a certificate exists, which needs DNS resolving first.
    - Known: `demo/src/CNAME` also carries the domain, but with
      `build_type: workflow` GitHub takes the domain from repo settings rather
      than the artifact, so the file alone was not enough.
    - Done when: shoreditch.mehcoleman.com serves the demo over HTTPS.

- [ ] Exercise `bridgetown.automation.rb` against a fresh site
    - Why: the automation is the headline install route — it is what the README
      and the demo's configuration post both tell people to run — and it has
      never been executed. The gem install path is proven (both `demo/` and
      `MEHColeman/blog` consume the theme), but that was done by hand, not by
      the automation.
    - Files: `bridgetown.automation.rb`
    - Known: it calls `ask()` twice, so it cannot be tested non-interactively
      in a background shell — that is why it was skipped rather than
      overlooked. `add_initializer` is passed a block returning `""` when both
      answers are blank; whether Bridgetown writes a bare `init :shoreditch`
      or something malformed in that case is the specific unknown.
    - Known: until 6 Aug 2026 its first prompt asked for an accent colour that
      had no effect at all, because the option was never wired to the CSS. That
      is fixed, so the automation is now worth testing — before, it would have
      confirmed a path leading nowhere.
    - Approach: `bridgetown new /tmp/apply-test --templates=erb`, then
      `bin/bridgetown apply /home/mark/dev/personal/shoreditch` from inside it.
      Run it twice — once answering both prompts, once leaving both blank.
      Check `config/initializers.rb` parses and the site builds.
    - Done when: both runs produce a site that builds and renders the sidebar.

- [ ] Publish 1.0.0 to RubyGems
    - Why: `MEHColeman/blog` currently depends on this theme through a git
      source, which pins a revision and clones on every deploy. A released gem
      makes `bundle add shoreditch` work for anyone, which is the whole point
      of the rewrite.
    - Approach: `gem build shoreditch.gemspec && gem push shoreditch-1.0.0.gem`.
      Needs a RubyGems account with the name `shoreditch` available — check
      that before announcing anything.
    - Done when: the blog's Gemfile can say `gem "shoreditch", "~> 1.0"`.

- [ ] Verify light mode
    - Why: the theme has only ever been looked at in dark mode. Headless
      Chrome requested dark for every screenshot taken on 6 Aug 2026, and the
      demo was rendering with the starter stylesheet forcing a white page
      before that — so no one has seen the theme's own light palette.
    - Known: the tokens exist in all four blocks (`:root`, the
      `prefers-color-scheme` media query, and both `data-theme` overrides).
      This is a looking-at task, not a building task.
    - Approach: open <http://localhost:4000> and use the sidebar toggle.
      Check the syntax palette on "Configuring Shoreditch" especially — the
      light and dark token sets are different values, and only dark has been
      seen.
    - Done when: light mode has been looked at on the index, a post, the CV
      page and a tag page, and anything illegible is fixed.

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

## Doing

## Done

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
