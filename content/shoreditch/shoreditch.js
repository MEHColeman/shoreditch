/*
 * Shoreditch's only script: the light/dark toggle.
 *
 * Shipped as a static file through the gem's source manifest, so consuming
 * sites do not have to import anything into their esbuild entry points.
 *
 * The initial theme is applied by a small inline script in the <head> so it
 * lands before first paint; this file only handles clicks afterwards.
 */
(function () {
  "use strict";

  var STORAGE_KEY = "shoreditch-theme";

  function systemTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  function currentTheme() {
    return document.documentElement.dataset.theme || systemTheme();
  }

  function apply(theme) {
    document.documentElement.dataset.theme = theme;
    try {
      localStorage.setItem(STORAGE_KEY, theme);
    } catch (e) {
      /* Private browsing, quota, or storage disabled — the toggle still works
         for this page view, it just will not be remembered. */
    }
  }

  function label(button, theme) {
    var next = theme === "dark" ? "light" : "dark";
    button.setAttribute("aria-label", "Switch to " + next + " theme");
    button.textContent = next === "dark" ? "Dark theme" : "Light theme";
  }

  /* The Giscus iframe loads with the OS preference and cannot see our toggle,
     so it would sit light on a dark page. Its postMessage API is the only way
     to change it after load. No-op when there is no comment thread. */
  function syncComments(theme) {
    var frame = document.querySelector("iframe.giscus-frame");
    if (!frame || !frame.contentWindow) return;
    frame.contentWindow.postMessage(
      { giscus: { setConfig: { theme: theme } } },
      "https://giscus.app"
    );
  }

  /* The contact panel ships the address in two halves so it never appears
     whole in the HTML. Joining them here is the only place it exists complete,
     which is the trade the Jekyll version made with document.write. */
  function revealEmail() {
    document.querySelectorAll(".sd-email").forEach(function (link) {
      var user = link.dataset.sdEmailUser;
      var host = link.dataset.sdEmailHost;
      if (!user || !host) return;
      link.href = "mailto:" + user + host;
      link.hidden = false;
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    revealEmail();

    var buttons = document.querySelectorAll("[data-shoreditch-theme-toggle]");
    if (!buttons.length) return;

    buttons.forEach(function (button) {
      label(button, currentTheme());

      button.addEventListener("click", function () {
        var next = currentTheme() === "dark" ? "light" : "dark";
        apply(next);
        syncComments(next);
        buttons.forEach(function (b) {
          label(b, next);
        });
      });
    });

    // Follow the OS while the reader has not made an explicit choice.
    window
      .matchMedia("(prefers-color-scheme: dark)")
      .addEventListener("change", function () {
        var stored;
        try {
          stored = localStorage.getItem(STORAGE_KEY);
        } catch (e) {
          stored = null;
        }
        if (!stored) {
          buttons.forEach(function (b) {
            label(b, systemTheme());
          });
        }
      });
  });
})();
