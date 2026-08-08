#!/usr/bin/env bash
# Exercises bridgetown.automation.rb against a fresh Bridgetown site.
#
# Scaffolds one pristine ERB site, pre-seeds the theme gem as a path source
# (the gem is not on RubyGems yet, so `add_gem "shoreditch"` cannot resolve
# there — re-run with EXERCISE_PRESEED=0 once it is published), then copies
# the pristine site per path and runs `bin/bridgetown apply` with the
# answers piped on stdin (Thor's ask() reads stdin fine without a TTY):
#
#   answered  both prompts answered  (#aa3355 / TEST)
#   blank     both prompts blank
#   quote     accent answer carries a double-quote — the generated
#             initializer must still parse or the answer must be rejected
#
# The apply target must be the automation FILE (or a URL): Bridgetown 2.2.2
# IO.reads the argument directly, so a checkout directory dies with EISDIR.
#
# Exits 0 only when every assertion on every path holds.
set -u

THEME_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${EXERCISE_WORKDIR:-$(mktemp -d /tmp/shoreditch-automation.XXXXXX)}"
mkdir -p "$WORK"
PRESEED="${EXERCISE_PRESEED:-1}"
FAILURES=0

say()  { printf '\n\033[1m== %s\033[0m\n' "$*"; }
pass() { printf '   ok: %s\n' "$*"; }
fail() { printf '   FAIL: %s\n' "$*"; FAILURES=$((FAILURES + 1)); }

# Every command that runs inside a generated site must not inherit the
# bundler environment of whichever bundle launched this script.
insite() {
  local dir="$1"; shift
  (cd "$dir" && env -u BUNDLE_GEMFILE -u BUNDLE_BIN_PATH -u BUNDLE_PATH \
      -u RUBYOPT -u RUBYLIB "$@")
}

# --- toolchain -------------------------------------------------------------

if [ -s "${NVM_DIR:-$HOME/.nvm}/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "${NVM_DIR:-$HOME/.nvm}/nvm.sh"
  nvm use 22 >/dev/null 2>&1 || nvm install 22 >/dev/null
fi
node_major="$(node --version 2>/dev/null | sed 's/^v//;s/\..*//')"
if [ "${node_major:-0}" -lt 22 ]; then
  echo "Node 22+ required (esbuild uses fs.globSync); found: $(node --version 2>&1)" >&2
  exit 2
fi

say "workdir: $WORK  (theme: $THEME_DIR)"

# --- pristine scaffold, built once and copied per path ---------------------

if [ ! -d "$WORK/pristine" ]; then
  say "scaffolding pristine site (bridgetown new)"
  BUNDLE_GEMFILE="$THEME_DIR/demo/Gemfile" bundle exec \
    bridgetown new "$WORK/pristine" --templates=erb >"$WORK/new.log" 2>&1 \
    || { echo "bridgetown new failed — $WORK/new.log:"; tail -20 "$WORK/new.log"; exit 2; }

  # bridgetown new shells out to bundler with this script's bundler env in
  # scope; redo the site's own install cleanly rather than trusting it.
  insite "$WORK/pristine" bundle install >>"$WORK/new.log" 2>&1 \
    || { echo "bundle install failed in pristine site"; tail -20 "$WORK/new.log"; exit 2; }
  [ -d "$WORK/pristine/node_modules" ] \
    || insite "$WORK/pristine" npm install --no-audit --no-fund >>"$WORK/new.log" 2>&1
  insite "$WORK/pristine" npm run esbuild >>"$WORK/new.log" 2>&1 \
    || { echo "esbuild failed in pristine site"; tail -20 "$WORK/new.log"; exit 2; }

  if [ "$PRESEED" = 1 ]; then
    printf '\ngem "shoreditch", path: "%s"\n' "$THEME_DIR" >>"$WORK/pristine/Gemfile"
    insite "$WORK/pristine" bundle install >>"$WORK/new.log" 2>&1 \
      || { echo "bundle install failed after pre-seed"; tail -20 "$WORK/new.log"; exit 2; }
  fi
fi

# --- per-path run + assertions ---------------------------------------------

run_path() {
  local name="$1" accent="$2" legend="$3"
  local site="$WORK/$name" init log
  init="$site/config/initializers.rb"
  log="$WORK/$name.apply.log"

  say "path: $name  (accent=${accent:-<blank>} legend=${legend:-<blank>})"
  rm -rf "$site"
  cp -a "$WORK/pristine" "$site"

  printf '%s\n%s\n' "$accent" "$legend" >"$WORK/$name.answers"
  if insite "$site" bin/bridgetown apply "$THEME_DIR/bridgetown.automation.rb" \
       <"$WORK/$name.answers" >"$log" 2>&1
  then pass "apply exited 0 (transcript: $log)"
  else fail "apply exited non-zero (transcript: $log)"; sed -n '1,40p' "$log"; fi

  grep -E 'bundle add|Gem .* already|could not find gem' -i "$log" | head -3 \
    | sed 's/^/   add_gem: /' || true

  if [ -f "$init" ]; then pass "config/initializers.rb exists"
  else fail "config/initializers.rb missing"; return; fi

  if insite "$site" ruby -c config/initializers.rb >/dev/null 2>&1
  then pass "initializer parses (ruby -c)"
  else fail "initializer DOES NOT PARSE:"; sed -n '1,30p' "$init" | sed 's/^/   | /'; fi

  grep -qE 'init :"?shoreditch"?' "$init" \
    && pass "init :shoreditch present" || fail "init :shoreditch missing"

  case "$name" in
    answered)
      grep -q 'accent "#aa3355"' "$init" \
        && pass 'accent "#aa3355" present' || fail "accent setting missing"
      grep -q 'logo_legend "TEST"' "$init" \
        && pass 'logo_legend "TEST" present' || fail "logo_legend setting missing"
      ;;
    blank)
      if grep -qE 'accent|logo_legend' "$init"
      then fail "blank path wrote settings anyway:"; grep -nE 'accent|logo_legend' "$init" | sed 's/^/   | /'
      else pass "no settings written on blank answers"; fi
      ;;
  esac

  [ -f "$site/src/_posts/_defaults.yml" ] \
    && grep -q 'layout: shoreditch/post' "$site/src/_posts/_defaults.yml" \
    && pass "_defaults.yml routes posts to shoreditch/post" \
    || fail "_defaults.yml missing or wrong"

  # Re-bundle so the built site reflects what apply did to the stylesheet;
  # a real site's next start/deploy does the same.
  insite "$site" npm run esbuild >"$WORK/$name.build.log" 2>&1 \
    || { fail "esbuild failed post-apply ($WORK/$name.build.log)"; return; }
  if insite "$site" env BRIDGETOWN_ENV=production bin/bridgetown build >>"$WORK/$name.build.log" 2>&1
  then pass "site builds"
  else fail "site build failed ($WORK/$name.build.log)"; tail -10 "$WORK/$name.build.log"; return; fi

  local post_html
  post_html="$(find "$site/output" -name index.html -path '*welcome*' | head -1)"
  if [ -n "$post_html" ] && grep -q 'sd-sidebar' "$post_html"
  then pass "built post renders the sidebar (${post_html#"$site"/})"
  else fail "no built post containing sd-sidebar"; fi

  grep -q 'sd-sidebar' "$site/output/index.html" \
    && pass "site index renders the sidebar" \
    || fail "site index does not render the sidebar"

  # The trample check: the starter stylesheet's main/body rules are exactly
  # what hid the theme on the demo for months. After apply, the site's own
  # stylesheet must no longer carry them (however the automation manages it).
  if grep -qE '^\s*(main|body|body\s*>\s*header)\s*\{' "$site/frontend/styles/index.css" 2>/dev/null
  then fail "starter stylesheet still tramples the theme (frontend/styles/index.css)"
  else pass "starter stylesheet does not trample the theme"; fi
}

run_path answered '#aa3355' 'TEST'
run_path blank    ''        ''
run_path quote    '#aa3355"' ''

say "result"
if [ "$FAILURES" -eq 0 ]; then
  echo "all assertions passed  (workdir kept at $WORK)"
  exit 0
else
  echo "$FAILURES assertion(s) failed  (workdir kept at $WORK)"
  exit 1
fi
