# shoreditch — tasks

Task list for **shoreditch**, maintained by agents and inbox triage. Standard
Obsidian checkboxes: `- [ ]` open, `- [x]` done.

## Inbox

- [ ] Turn on GitHub Pages so the demo deploys
    - Why: `.github/workflows/demo.yml` builds `demo/` and calls
      `actions/deploy-pages`, but Pages is not enabled on this repo, so the
      deploy job fails. Until it is enabled every push to master shows a red
      workflow.
    - Approach: repo Settings → Pages → Source: **GitHub Actions**. Then add
      `shoreditch.mehcoleman.com` as the custom domain (`demo/src/CNAME`
      already carries it) and create the DNS record at DNSimple.
    - Known: the workflow triggers on `master`, not `main` — this repo's
      default branch was left as `master` rather than renaming a public repo.
    - Done when: shoreditch.mehcoleman.com serves the demo over HTTPS.

- [ ] Publish 1.0.0 to RubyGems
    - Why: `MEHColeman/blog` currently depends on this theme through a git
      source, which pins a revision and clones on every deploy. A released gem
      makes `bundle add shoreditch` work for anyone, which is the whole point
      of the rewrite.
    - Approach: `gem build shoreditch.gemspec && gem push shoreditch-1.0.0.gem`.
      Needs a RubyGems account with the name `shoreditch` available — check
      that before announcing anything.
    - Done when: the blog's Gemfile can say `gem "shoreditch", "~> 1.0"`.

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
