# Installs Shoreditch into an existing Bridgetown site.
#
#   bin/bridgetown apply https://github.com/MEHColeman/shoreditch
#
# The theme's stylesheet and script ship as static files through the gem's
# source manifest, so there is nothing to add to esbuild entry points and no
# NPM package to install.
#
# This can run against a site with real content, so every destructive step is
# gated on the file being *exactly* the untouched `bridgetown new` scaffold
# (whitespace aside). Anything a site has edited is left alone with a note.
# The gate is deliberately strict: a newer Bridgetown scaffold this does not
# recognise is treated as "not ours to touch", so the automation degrades to
# advice rather than deleting someone's work.

add_gem "shoreditch"

# Both answers are written into the generated initializer as Ruby string
# literals (`accent "…"`). Reject any answer that could break out of the
# literal or smuggle interpolation (`#{…}`, `#@…`, `#$…`) rather than trying
# to escape it: Bridgetown's initializer insertion rewrites backslashes, so an
# escaped answer can be un-escaped on its way into the file — but an answer
# carrying none of these characters needs no escaping and cannot be reactived.
# A colour and a short badge never need them; anything that does is set by hand.
unsafe = ->(text) { text.match?(/["\\\r\n]|#[{@$]/) }

accent = ask("Accent colour (hex, blank for the default slate blue)?").to_s.strip
if unsafe.call(accent)
  say "Ignoring the accent — it contained characters not allowed in a colour. " \
      "Set `accent` by hand in config/initializers.rb.", :yellow
  accent = ""
end

legend = ask("Badge text under the logo (blank for none)?").to_s.strip
if unsafe.call(legend)
  say "Ignoring the badge text — it contained characters that aren't allowed. " \
      "Set `logo_legend` by hand in config/initializers.rb.", :yellow
  legend = ""
end

add_initializer :shoreditch do
  settings = []
  settings << %(accent "#{accent}") unless accent.empty?
  settings << %(logo_legend "#{legend}") unless legend.empty?

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

# Collapse whitespace so indentation and line-ending differences do not read
# as edits; any real change to the content does.
normalise = ->(text) { text.gsub(/\s+/, " ").strip }

pristine_default = <<~'ERB'
  <!doctype html>
  <html lang="<%= site.locale %>">
    <head>
      <%= render "head", metadata: site.metadata, title: data.title %>
    </head>
    <body class="<%= data.layout %> <%= data.page_class %>">
      <%= render Shared::Navbar.new(metadata: site.metadata, resource: resource) %>

      <main>
        <%= yield %>
      </main>

      <%= render "footer", metadata: site.metadata %>
    </body>
  </html>
ERB

# `bridgetown new` generates page.erb and post.erb identically.
pristine_page_post = <<~'ERB'
  ---
  layout: default
  ---

  <h1><%= data.title %></h1>

  <%= yield %>
ERB

pristine_css = <<~'CSS'
  :root {
    --body-background: #f2f2f2;
    --body-color: #444;
    --heading-color: black;
    --action-color: #d64045;
  }

  body {
    background: var(--body-background);
    color: var(--body-color);
    font-family: BlinkMacSystemFont, -apple-system, "Segoe UI", "Roboto", "Oxygen",
      "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue",
      "Helvetica", "Arial", sans-serif;
    margin: 0 8px;
    font-size: 108%;
    line-height: 1.5;
  }

  a {
    color: var(--action-color);
    text-decoration: underline;
    text-decoration-color: #ffb088;
  }

  h1 {
    margin: 1rem 0 3rem;
    text-align: center;
    font-weight: 900;
    font-size: 2.5rem;
    color: var(--heading-color);
    line-height: 1.2;
  }

  body > header {
    margin: 1rem;
    text-align: center;
  }

  body > header img {
    display: inline-block;
    width: 400px;
    max-width: 100%;
  }

  body > nav ul {
    margin: 2rem 0;
    padding: 0;
    list-style-type: none;
    display: flex;
    justify-content: center;
    gap: 1.5rem;
    font-size: 1.3rem;
    font-weight: bold;
  }

  body > nav a {
    text-decoration: none;
  }

  main {
    margin: 2rem auto 4rem;
    max-width: 65rem;
    min-height: calc(100vh - 200px);
    padding: 25px 25px 50px;
    background: white;
    box-shadow: 2px 3px 3px #ddd;
    border-radius: 3px;

    @media (max-width: 500px) {
      padding: 16px 16px 50px;
    }
  }

  footer {
    text-align: center;
    margin-bottom: 4rem;
    font-size: 1em;
  }

  hr {
    border: none;
    border-top: 2px dotted #bbb;
    margin: 3rem 0;
  }
CSS

# The starter stylesheet styles body and main directly, and a site's own CSS
# loads after the theme's — so left in place it pulls the theme apart (it once
# cost the demo its entire appearance). Replace it only when it is exactly the
# untouched starter.
starter_css = "frontend/styles/index.css"
if File.exist?(starter_css)
  if normalise.call(File.read(starter_css)) == normalise.call(pristine_css)
    say "Clearing the starter stylesheet — its body/main rules override the theme…", :green
    create_file starter_css, <<~CSS, force: true
      /* Your site's styles load after the theme's, so anything here overrides
         Shoreditch. Prefer overriding the theme's custom properties (see the
         README) to styling body, main, or bare a directly. */
    CSS
  else
    say "Left frontend/styles/index.css alone — it differs from the starter. " \
        "Your CSS loads after the theme's, so remove any rules on body, main " \
        "or bare a that fight it.", :yellow
  end
end

say "Pointing your layouts at the theme…", :green

# The scaffold's own layouts beat the theme's for every page whose front
# matter names them — including the scaffold's welcome post — so a fresh site
# would not render as the theme anywhere. Retire each starter layout only when
# it is exactly the untouched scaffold; an edited layout is the site's own and
# stays, with a note.
layouts = {
  "default" => [pristine_default,   "shoreditch/default"],
  "page"    => [pristine_page_post, "shoreditch/page"],
  "post"    => [pristine_page_post, "shoreditch/post"],
}

retired = {}
layouts.each do |name, (pristine, replacement)|
  file = "src/_layouts/#{name}.erb"
  next unless File.exist?(file)

  if normalise.call(File.read(file)) == normalise.call(pristine)
    remove_file file
    retired[name] = replacement
  else
    say "Left src/_layouts/#{name}.erb alone — it differs from the starter. " \
        "Point pages that use it at #{replacement} yourself.", :yellow
  end
end

# Repoint the pages that named a retired layout — but only inside the leading
# `---`…`---` front matter, so a `layout:` line in a post's body or a fenced
# code block is never touched, and tolerant of quoted values (layout: "post").
unless retired.empty?
  Dir.glob("src/**/*.{md,erb,serb,liquid,html}").each do |page|
    next unless File.file?(page)

    text = File.read(page)
    next unless text =~ /\A(---[ \t]*\r?\n)(.*?\r?\n)(---[ \t]*\r?\n)(.*)\z/m

    open_fence, front, close_fence, body = $1, $2, $3, $4
    changed = false
    retired.each do |name, replacement|
      front = front.sub(/^(layout:[ \t]*)["']?#{Regexp.escape(name)}["']?[ \t]*$/) do
        changed = true
        "#{$1}#{replacement}"
      end
    end
    File.write(page, open_fence + front + close_fence + body) if changed
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
