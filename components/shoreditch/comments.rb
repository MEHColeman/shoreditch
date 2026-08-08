# frozen_string_literal: true

# The comments slot.
#
# The theme ships Giscus (comments stored as GitHub Discussions) as the one
# provider it knows how to configure, but nothing here is Giscus-specific from
# a consuming site's point of view: a site that wants something else overrides
# this component by putting its own `components/shoreditch/comments.erb` in
# place. Site files take precedence over the gem's source manifest, so no fork
# and no layout copy is needed.
#
# Off unless configured. Set in config/initializers.rb:
#
#   init :shoreditch do
#     comments({
#       repo: "you/your-repo", repo_id: "R_...",
#       category: "Comments",  category_id: "DIC_...",
#     })
#   end
#
# The four values come from https://giscus.app after enabling Discussions on
# the repository. A single post opts out with `comments: false` in front matter.
class Shoreditch::Comments < Bridgetown::Component
  def initialize(site:, resource:)
    @site = site
    @resource = resource
  end

  attr_reader :site, :resource

  def render?
    resource.data.comments != false && settings.is_a?(Hash) && required_keys_present?
  end

  def settings
    site.config.shoreditch[:comments]
  end

  # Giscus silently renders nothing if any of these are missing, which is a
  # miserable thing to debug, so treat a partial config as "off".
  def required_keys_present?
    %i[repo repo_id category category_id].all? { |key| settings[key].to_s.strip != "" }
  end

  def repo = settings[:repo].to_s
  def repo_id = settings[:repo_id].to_s
  def category = settings[:category].to_s
  def category_id = settings[:category_id].to_s
end
