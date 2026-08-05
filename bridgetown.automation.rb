# Installs Shoreditch into an existing Bridgetown site.
#
#   bin/bridgetown apply https://github.com/MEHColeman/shoreditch
#
# The theme's stylesheet and script ship as static files through the gem's
# source manifest, so there is nothing to add to esbuild entry points and no
# NPM package to install.

add_gem "shoreditch"

accent = ask("Accent colour (hex, blank for the default slate blue)?")
legend = ask("Badge text under the logo (blank for none)?")

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

say "Pointing your layouts at the theme…", :green

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
