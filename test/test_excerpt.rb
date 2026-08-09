# frozen_string_literal: true

require_relative "test_helper"

class TestExcerpt < Minitest::Test
  include Shoreditch::TestHelpers

  def extract(markdown)
    Shoreditch::Excerpt.extract(render_markdown(markdown))
  end

  def assert_balanced(tag, html)
    opens = html.scan(/<#{tag}[\s>]/).size
    closes = html.scan("</#{tag}>").size
    assert_equal opens, closes, "expected balanced <#{tag}> tags in: #{html}"
    assert opens.positive?, "expected at least one <#{tag}> in: #{html}"
  end

  def test_plain_paragraph
    excerpt = extract("One short paragraph.\n\nA second paragraph.\n")

    assert_equal "<p>One short paragraph.</p>", excerpt
  end

  def test_hard_wrapped_paragraph
    excerpt = extract("A paragraph wrapped\nacross source lines.\n\nA second paragraph.\n")

    # The whole paragraph survives, not just its first source line; the
    # source's hard wrap may normalise to a space.
    assert_match(/wrapped\sacross source lines\./, excerpt)
    assert_balanced "p", excerpt
    refute_includes excerpt, "second"
  end

  def test_blockquote_opener_is_balanced
    excerpt = extract("> Well begun is half done.\n\nThe paragraph after the quote.\n")

    assert_balanced "blockquote", excerpt
    assert_includes excerpt, "half done"
    refute_includes excerpt, "paragraph after"
  end

  def test_code_fence_opener_yields_following_paragraph
    markdown = <<~MD
      ```ruby
      def greet(name)
        "Hello, \#{name}!"
      end
      ```

      The paragraph after the code.
    MD
    rendered = render_markdown(markdown)

    assert_includes rendered, "highlight" # the fixture really is Rouge output
    excerpt = Shoreditch::Excerpt.extract(rendered)

    assert_equal "<p>The paragraph after the code.</p>", excerpt
    refute_includes excerpt, "highlight"
    refute_includes excerpt, "<pre"
  end

  def test_more_marker_wins_and_is_balanced
    excerpt = extract("Before the fold.<!--more--> After the fold.\n\nA second paragraph.\n")

    assert_includes excerpt, "Before the fold."
    refute_includes excerpt, "After the fold"
    assert_balanced "p", excerpt
  end

  def test_message_paragraph_keeps_its_class
    excerpt = extract("A gentle note.\n{:.message}\n\nA second paragraph.\n")

    assert_includes excerpt, %(class="message")
    assert_balanced "p", excerpt
    refute_includes excerpt, "second"
  end

  def test_no_prose_falls_back_to_first_block_balanced
    excerpt = extract("```ruby\ndef x = 1\n```\n")

    assert_balanced "div", excerpt
    assert_includes excerpt, "def x = 1"
  end

  def test_empty_content
    assert_equal "", Shoreditch::Excerpt.extract("")
    assert_equal "", Shoreditch::Excerpt.extract(nil)
  end
end
