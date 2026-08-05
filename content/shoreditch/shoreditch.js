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

  document.addEventListener("DOMContentLoaded", function () {
    var buttons = document.querySelectorAll("[data-shoreditch-theme-toggle]");
    if (!buttons.length) return;

    buttons.forEach(function (button) {
      label(button, currentTheme());

      button.addEventListener("click", function () {
        var next = currentTheme() === "dark" ? "light" : "dark";
        apply(next);
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
