# Publish the gem from a pushed version tag by trusted publishing

**Status:** queued
**Branch:** docs/trusted-publishing (plan only; the build uses feat/trusted-publishing)
**Base:** master
**PR:** none yet
**Issue:** #6
**Todo:** issue #6 (P3, effort S)
**Goal:** none — the repository keeps no goals file
**Carriers:** `.github/workflows/release.yml` (new); `scripts/release-tag-check.sh` (new); the release process text in `docs/seed.md` and `README.md`; the local `gem push` fallback, which stays as documented
**Requirements:** REQ-F-1, REQ-F-2, REQ-N-1 (new entries from the approved catalog delta; UC-1 is the new use case)
**Planned at:** edc50dff2b2025d5921d3638bcf06e92100cf40f

## Context

Every release of the gem ends with a local `gem push`. The account's RubyGems API key demands a one-time password on each push. A release therefore needs the maintainer at a real terminal.

RubyGems trusted publishing removes the key. GitHub Actions asks GitHub for a short-lived OpenID Connect token during one workflow run, and RubyGems swaps it for a short-lived push credential. Nothing long-lived is stored.

The outcome wanted: pushing a bare version tag such as `1.2.0` tests, checks, builds and publishes the gem with no person at a terminal and no stored API key.

No question was posted to the tracker. The issue's approved requirements already settle scope, shape, done and constraints. The decisions below come from its `## Decisions` section. The repository keeps no `docs/system/decisions.md`, so no standing ruling applies.

## What's already known

- Release process today: `docs/seed.md`, section "Current state", last paragraph. Bump `lib/shoreditch/version.rb`, roll `CHANGELOG.md`, refresh `demo/Gemfile.lock` with `cd demo && bundle lock` in the same commit, commit to master, tag with the bare version, push, then `gem push` in a real terminal.
- Existing tags are bare versions: `0.9.0` and `1.1.0`. The new workflow matches that form and refuses a `v` prefix.
- `Shoreditch::VERSION` is `"1.1.0"` in `lib/shoreditch/version.rb`, one line: `  VERSION = "1.1.0"`.
- `Rakefile` defines a `test` task over `test/test_*.rb`. `bundle exec rake test` runs it. `test/test_helper.rb` loads minitest, kramdown and rouge.
- `.github/workflows/` holds only `demo.yml`. It uses `actions/checkout@v4`, `ruby/setup-ruby@v1` with Ruby 3.4 and `bundler-cache: true`. The release workflow reuses those versions.
- `shoreditch.gemspec` builds `spec.files` from `git ls-files` and drops `demo`, `test`, `scripts`, `features`, `docs`, paths that start with `.git` (so `.github/`) and `Rakefile`. Other dotfiles such as `.project-type` still ship. The new workflow, script, feature file and tests are therefore all outside the gem. No gemspec change is needed for them.
- There is no root `Gemfile.lock` (it is in `.gitignore`). The `Gemfile` is `gemspec` only.
- There is no `justfile`, no `features/` directory, no `docs/requirements.md` and no `docs/stories.md`. `README.md` has no release section. The build creates the feature directory, the two catalog files and the README section.
- The host runs Ruby 3.1.2, and the gemspec asks for 3.3 or newer. So `bundle exec` stops with `Bundler::VersionConflict` on the host. The host has `cucumber` 10.2.0 and `minitest` 5.15.0 installed system-wide, but not `kramdown`, `rouge` or `shellcheck`. Every verification command below therefore runs without Bundler and uses only Ruby's standard library.
- Ruled out: `rubygems/release-gem`. It runs `rake release`, which needs `bundler/gem_tasks` in the Rakefile and tries to create and push the tag. The tag already exists, because pushing it starts the run.
- Ruled out: a GitHub deployment environment. Trusted publishing needs only the owner, repository and workflow file name. An environment adds a second setting to keep in step, with no gain for one maintainer.
- Ruled out: committing from the workflow. The refresh of `demo/Gemfile.lock` stays a manual step in the release commit.
- GitHub tag filters use glob patterns, not regular expressions. `'[0-9]+.[0-9]+.[0-9]+'` matches `1.2.0`. In the filter, `+` repeats the preceding character class and `.` is a literal dot. It does not match `v1.2.0` or `1.2.0.rc1`.
- A workflow with only `on.push.tags` does not run on a branch push. A `branches` key must be absent.

## Registry delta

- `docs/requirements.md` — created on this branch. It holds REQ-F-1, REQ-F-2 and REQ-N-1 as written in the approved catalog delta.
- `docs/stories.md` — created on this branch. It holds UC-1 as written in the approved catalog delta.
- `docs/design.md`, `docs/architecture.md`, `docs/context.md` — the repository keeps none of these. Unchanged.
- `docs/seed.md` — the release-process paragraph is rewritten, and the Layout block gains the workflow, the script and `features/`.
- `README.md` — gains a "Releasing" section under "Development".
- `CHANGELOG.md` — "Unreleased" gains one "Added" entry for the release workflow. It changes nothing a consuming site sees, so the entry says so.
- `docs/acceptance.md` — written on this branch as the last act before the merge, as a criteria-only entry from the criteria below.

## Approach

1. Write `scripts/release-tag-check.sh`. It takes the tag as its first argument and an optional version-file path as its second, defaulting to `lib/shoreditch/version.rb` beside the script's parent directory. It reads the version with `sed -n` on the `VERSION = "…"` line. It compares the two strings exactly. On a match it exits 0. On a mismatch it prints `tag: <tag>` and `version: <version>` to standard error and exits 1. On a usage or read error it exits 2.
2. Commit `scripts/release-tag-check.sh` as executable (mode 100755), because the workflow step and criteria 3 and 4 run it by path. Check with `git ls-files -s scripts/release-tag-check.sh`.
3. Write `test/test_release_tag_check.rb` (minitest). It requires only `minitest/autorun`, not `test/test_helper.rb`, so it runs on the host without kramdown or rouge. It runs the script through `Open3.capture3` against temporary version files. It runs under `bundle exec rake test`, so the release workflow runs it too.
4. Write `.github/workflows/release.yml`.
   - Trigger: `on.push.tags: ['[0-9]+.[0-9]+.[0-9]+']`, with no `branches` key.
   - Top-level `permissions: contents: read`. The one job sets its own `permissions` block with both `contents: read` and `id-token: write`. A job-level block replaces the top-level one, so `contents: read` is listed again to keep `actions/checkout` working.
   - Steps in order: `actions/checkout@v4`; `ruby/setup-ruby@v1` (Ruby 3.4, `bundler-cache: true`); a tag check step that runs `scripts/release-tag-check.sh "$TAG"` with `TAG` set from `github.ref_name` in `env:`; `bundle exec rake test`; `gem build shoreditch.gemspec`; `rubygems/configure-rubygems-credentials`; `gem push` of the built file.
   - No step sets `continue-on-error` or `if:`. A failed step stops the job before `gem push`.
   - Pin `rubygems/configure-rubygems-credentials` to a release tag. Worker runs cannot read other repositories, so the build uses the major tag `v1` from the action's documented usage and records in the progress log that the owner must confirm it. If the owner names a newer tag, the build uses that.
5. Prove the feature file with Cucumber, run as the system `cucumber` command. The gemspec gains no dependency, so the release run does not install Cucumber. Write `features/trusted-publishing.feature` with the seven approved scenarios. Write `features/step_definitions/trusted_publishing_steps.rb` and `features/support/env.rb`. The steps use only the standard library and parse the workflow with `YAML.safe_load`, run the script through `Open3`, and read the docs. The step for the order criterion also asserts that no step before `gem push` has `continue-on-error`. That assertion closes the gap the requirements check noted in issue #18.
6. Write `docs/requirements.md` and `docs/stories.md` from the approved catalog delta, word for word.
7. Rewrite the release paragraph in `docs/seed.md`, add the "Releasing" section to `README.md`, and add the `CHANGELOG.md` entry. Both documents say: a pushed bare version tag publishes the gem through the release workflow; the trusted publisher is registered once on rubygems.org by the gem's owner (owner `MEHColeman`, repository `shoreditch`, workflow `release.yml`, no environment); the local `gem push` stays the fallback and still needs the one-time password.
8. Write the `docs/acceptance.md` entry as the last act before the merge.

### What could go wrong

- Inputs. The tag name comes from `github.ref_name`, which anyone with push access sets. The workflow passes it through `env:` and the script receives it as a quoted argument, so it is never spliced into shell text. The script uses `[ "$a" = "$b" ]` and `printf '%s\n'`, never `eval` or an unquoted expansion. The version file is read with `sed -n` and the result is only compared and printed.
- Edge cases for the script. No argument: exit 2 with a usage line. Empty tag: exit 1, since it differs from the version. A tag with a `v` prefix, or the right version with trailing text: exit 1. A version file that is missing, empty or has no `VERSION` line: exit 2 and no comparison. A file with two `VERSION` lines: the first is used. A file with Windows line endings: the carriage return is stripped before the compare. A tag with a newline cannot come from git, and an embedded newline passed by hand still fails the exact comparison. Each case has a unit test.
- Edge cases for the workflow. A tag such as `1.2.0.rc1` or `v1.2.0` does not trigger the workflow. A tag on a commit whose version file differs fails at the tag check. A pre-existing version on RubyGems makes `gem push` fail loudly, which is the intended result.
- Where it runs. The workflow runs on GitHub's `ubuntu-latest` runner only. The script and tests also run on the maintainer's host. The host has Ruby 3.1, so the host cannot run the gem's tests through Bundler. The script test and the feature steps need only Ruby's standard library, `sed` and the system `cucumber`, so they run on the host. The registration on rubygems.org and the first real release cannot be done by a branch or by the worker. They are verification items for the owner.
- Other places that state the behaviour. `docs/seed.md` (release paragraph and Layout block), `README.md` (new section), `CHANGELOG.md`, `docs/acceptance.md`, and the new `docs/requirements.md` and `docs/stories.md`. `git grep -n 'gem push'` is run at build time to find any further mention.
- Criteria that pass on the default tip. Each of the seven scenarios needs a file or entry that master lacks, so each fails before the change.
- Existing mechanism. `git grep -n 'release\|gem push'` shows only the prose in `docs/seed.md` and the journal. No release script or workflow exists. `gh pr list --search release` shows no open pull request on the subject.
- Supply chain. The credentials action runs with `id-token: write`. It is pinned to a release tag, and the permission is granted to the one job, not to the workflow.

No acceptance criterion was added at planning. The seven below are the approved snapshot, carried verbatim. The standing "living set" scenario from the template is not added, because the repository has no `living-set-check` command.

## Acceptance criteria

Feature file: `features/trusted-publishing.feature`

- [ ] **Scenario: The release workflow runs on a bare version tag only**
  Given the file `.github/workflows/release.yml` on the branch
  When its trigger section is read
  Then it runs on a push of a tag matching the bare version form, such as `1.2.0`
  And it does not run on a push to any branch

- [ ] **Scenario: The release workflow authenticates by trusted publishing**
  Given the file `.github/workflows/release.yml` on the branch
  When its permissions and steps are read
  Then the publishing job grants `id-token: write`
  And it obtains RubyGems credentials with the `rubygems/configure-rubygems-credentials` action
  And no step reads a RubyGems API key from a secret

- [ ] **Scenario: A tag that matches the version passes the tag check**
  Given `lib/shoreditch/version.rb` sets `Shoreditch::VERSION` to a version
  When `scripts/release-tag-check.sh` runs with that version as the tag
  Then it exits 0

- [ ] **Scenario: A tag that differs from the version fails the tag check**
  Given `lib/shoreditch/version.rb` sets `Shoreditch::VERSION` to a version
  When `scripts/release-tag-check.sh` runs with `v` followed by that version, or with a different version
  Then it exits non-zero
  And it prints both the tag and the version

- [ ] **Scenario: The workflow tests and checks before it publishes**
  Given the file `.github/workflows/release.yml` on the branch
  When its steps are read in order
  Then `scripts/release-tag-check.sh` and `bundle exec rake test` run before `gem build`
  And `gem build` runs before `gem push`

- [ ] **Scenario: The release process is documented**
  Given `docs/seed.md` and `README.md` on the branch
  When the release process section is read
  Then it says a pushed bare version tag publishes the gem through the release workflow
  And it names the one-time registration of the trusted publisher on rubygems.org
  And it keeps the local `gem push` as the fallback

- [ ] **Scenario: The catalog holds the approved entries**
  Given `docs/requirements.md` and `docs/stories.md` on the branch
  When they are read
  Then they hold REQ-F-1, REQ-F-2, REQ-N-1 and UC-1 as written in the catalog delta

## Verification

Targeted commands, each with a timeout:

```
timeout 300 cucumber features/trusted-publishing.feature   # 7 scenarios, all passed (system cucumber, no Bundler)
timeout 300 ruby test/test_release_tag_check.rb            # the script's edge cases pass (minitest only)
timeout 120 scripts/release-tag-check.sh 1.1.0             # exit 0 at version 1.1.0
timeout 120 scripts/release-tag-check.sh v1.1.0; echo $?   # prints tag and version, exit 1
timeout 60 sh -n scripts/release-tag-check.sh              # the script parses
```

`bundle exec rake test` and `shellcheck` do not run on the worker host. The release workflow runs `bundle exec rake test` on Ruby 3.4 for each tag. The owner may run `shellcheck` where it is installed. Neither is a gate for this plan.

Checks a branch cannot observe. These belong to the owner and are reported, not ticked:

- The trusted publisher is registered once on rubygems.org, in the gem's settings, with owner `MEHColeman`, repository `shoreditch`, workflow `release.yml` and no environment. Only the gem's owner can do it.
- `gh secret list` on the repository shows no RubyGems key. This covers REQ-N-1 for repository secrets.
- The first real release pushes a bare tag, the workflow run goes green, and the new version appears on rubygems.org.

Standing check: every document named in the registry delta is updated on this branch, and `git grep -n 'gem push'` shows no sentence that still calls the local push the only route.

## Progress log

- Plan written at master tip `edc50df`. Nothing built yet.

## Review

## Open questions

- None that change what is built. The approved criteria name a feature file, so Cucumber proves it. It runs from the system install and adds no gem dependency.
