---
title: Opening with Code
last_updated: 2025-02-11
last_verified: 2025-02-11
tags: [ shoreditch, demo ]
---

```ruby
def excerpt(post)
  post.first_paragraph
end
```

A code dump makes a poor preview, so a post that opens with a fenced code
block excerpts its first paragraph instead — the one you are reading on the
index right now.

The rest of the post carries on as normal. This one exists to demonstrate the
code-fence-opening case in the demo's index.
