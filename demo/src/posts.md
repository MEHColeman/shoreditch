---
layout: shoreditch/page
title: Posts
nav_order: 2
---

<% collections.posts.resources.sort_by(&:date).reverse.group_by { |post| post.date.year }.each do |year, posts| %>
  <h2><%= year %></h2>

  <ul class="sd-archive">
    <% posts.each do |post| %>
      <li>
        <a href="<%= post.relative_url %>"><%= post.data.title %></a>
        <time datetime="<%= post.date.strftime("%Y-%m-%d") %>"><%= post.date.strftime("%-d %B") %></time>
      </li>
    <% end %>
  </ul>
<% end %>
