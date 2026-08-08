# Installs Shoreditch into an existing Bridgetown site.
#
#   bin/bridgetown apply https://github.com/MEHColeman/shoreditch
#
# The theme's stylesheet and script ship as static files through the gem's
# source manifest, so there is nothing to add to esbuild entry points and no
# NPM package to install.

add_gem "shoreditch"

# The answers are interpolated into generated Ruby below, so characters that
# could end the string literal early are dropped rather than written through.
accent = ask("Accent colour (hex, blank for the default slate blue)?").to_s.delete(%(\\")).strip
legend = ask("Badge text under the logo (blank for none)?").to_s.delete(%(\\")).strip

add_initializer :shoreditch do
  settings = []
  settings << %(accent "#{accent}") unless accent.to_s.strip.empty?
  settings << %(logo_legend "#{legend}") unless legend.to_s.strip.empty?

  if settings.empty?
    ""
  else
    <<~RUBY
      do
        #{settings.join("\n  ")}
      end
    RUBY
  end
end

# The starter stylesheet that `bridgetown new` generates styles body and main
# directly, and a site's own CSS loads after the theme's — so left in place it
# pulls the theme apart (it once cost the demo its entire appearance). Replace
# it only when it is recognisably the untouched starter; a stylesheet someone
# has edited is theirs to reconcile.
starter_css = "frontend/styles/index.css"
if File.exist?(starter_css) && File.read(starter_css).include?("--body-background")
  say "Clearing the starter stylesheet — its body/main rules override the theme…", :green
  create_file starter_css, <<~CSS, force: true
    /* Your site's styles load after the theme's, so anything here overrides
       Shoreditch. Prefer overriding the theme's custom properties (see the
       README) to styling body, main, or bare a directly. */
  CSS
else
  say "Check your stylesheet for rules on body/main/a — your CSS loads after the theme's and will override it.", :yellow
end

say "Pointing your layouts at the theme…", :green

# The scaffold's own layouts beat the theme's for every page whose front
# matter names them — including the scaffold's welcome post — so a fresh site
# would not render as the theme anywhere. Retire each starter layout only
# when it is recognisably untouched, and point the pages that used it at the
# theme's equivalent; an edited layout is the site's own and stays.
{
  "default" => ["Shared::Navbar", "shoreditch/default"],
  "page"    => ["<h1><%= data.title %></h1>", "shoreditch/page"],
  "post"    => ["<h1><%= data.title %></h1>", "shoreditch/post"],
}.each do |name, (marker, replacement)|
  layout_file = "src/_layouts/#{name}.erb"
  next unless File.exist?(layout_file) && File.read(layout_file).include?(marker)

  remove_file layout_file
  Dir.glob("src/**/*.{md,erb,serb,liquid,html}").each do |page|
    gsub_file page, /^layout:\s*#{name}\s*$/, "layout: #{replacement}"
  end
end

# Posts and pages need to reference the theme's layouts. A site that already
# has its own layouts keeps them; these defaults only apply where there is
# nothing already.
create_file "src/_posts/_defaults.yml", force: false do
  <<~YAML
    layout: shoreditch/post
  YAML
end

say <<~TEXT, :green

  Shoreditch installed.

  Next steps:

    1. Set `layout: shoreditch/page` on your standalone pages.
    2. Add these to src/_data/site_metadata.yml:

         logo: /images/your-logo.png
         logo_link: /about/
         tagline: Your tagline

    3. Give pages a `nav_order:` to put them in the sidebar. Pages with
       `exclude: true` never appear there.

  The full option list is in the theme README.
TEXT
