// Copyright 2023-2026 Ant Investor Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Shop widget: a shop's public storefront embedded in its own site.
//
// It reads the catalogue commerce publishes for shops that opted in
// (GET {apiUrl}/shop/{slug}/catalogue) and posts the order form to the same
// guest checkout the shop's /shop/{slug} page uses. The page carries no
// credentials of any kind: the shop's opt-in is what makes it public, the
// buyer is identified by the name and contact they type, and payment
// happens on the hosted payment page checkout redirects to. Every element
// is built through the DOM, so shop text never becomes markup.
(function () {
  "use strict";

  var MAX_QUANTITY = 99;
  var QTY_PREFIX = "qty.";

  function el(tag, attrs, children) {
    var node = document.createElement(tag);
    Object.keys(attrs || {}).forEach(function (name) {
      var value = attrs[name];
      if (value === undefined || value === null || value === false) return;
      if (name === "text") {
        node.textContent = String(value);
      } else {
        node.setAttribute(name, value === true ? "" : String(value));
      }
    });
    (children || []).forEach(function (child) {
      if (child) node.appendChild(child);
    });
    return node;
  }

  function trimSlash(url) {
    return String(url || "").replace(/\/+$/, "");
  }

  // A fresh key per form: resubmitting the same form places one order.
  function newKey() {
    var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    var bytes = new Uint8Array(32);
    window.crypto.getRandomValues(bytes);
    var key = "";
    for (var i = 0; i < bytes.length; i++) key += alphabet.charAt(bytes[i] % alphabet.length);
    return key;
  }

  // checkoutAction resolves where the order form posts. Commerce answers
  // with an absolute address when it knows its public one; otherwise the
  // path is under the configured API address.
  function checkoutAction(apiUrl, checkoutUrl) {
    if (/^https:\/\//i.test(checkoutUrl)) return checkoutUrl;
    if (checkoutUrl.charAt(0) === "/") return trimSlash(apiUrl) + checkoutUrl;
    return trimSlash(apiUrl) + "/" + checkoutUrl;
  }

  function mediaUrl(base, id) {
    if (!base || !id) return "";
    return trimSlash(base) + "/" + encodeURIComponent(id);
  }

  function showMessage(root, className, text) {
    root.replaceChildren(el("div", { class: className, role: "alert" }, [
      el("p", { class: "ai-shop-error-message", text: text }),
    ]));
  }

  function renderItem(item, config) {
    var image = mediaUrl(config.mediaBaseUrl, (item.media_ids || [])[0]);
    var rows = (item.variants || []).map(function (variant) {
      var label = variant.name || "Quantity";
      var price = el("span", { class: "ai-shop-card-price", text: variant.currency + " " + variant.amount });
      var control = variant.in_stock
        ? el("input", {
            class: "ai-shop-form-input ai-shop-qty",
            type: "number",
            name: variant.field,
            min: 0,
            max: MAX_QUANTITY,
            step: 1,
            inputmode: "numeric",
            placeholder: "0",
            "aria-label": "Quantity of " + item.name + " " + label,
          })
        : el("span", { class: "ai-shop-card-stock ai-shop-card-stock--out", text: "Out of stock" });
      return el("div", { class: "ai-shop-variant-row" }, [el("span", { text: label }), price, control]);
    });
    return el("section", { class: "ai-shop-card" }, [
      image ? el("img", { class: "ai-shop-card-image", src: image, alt: item.name, loading: "lazy" }) : null,
      el("div", { class: "ai-shop-card-body" }, [
        el("h3", { class: "ai-shop-card-name", text: item.name }),
        item.description ? el("p", { class: "ai-shop-detail-description", text: item.description }) : null,
      ].concat(rows)),
    ]);
  }

  function field(id, label, input, hint) {
    return el("div", { class: "ai-shop-form-group" }, [
      el("label", { class: "ai-shop-form-label", for: id }, [
        document.createTextNode(label),
        hint ? el("span", { class: "ai-shop-hint", text: " " + hint }) : null,
      ]),
      input,
    ]);
  }

  function render(root, config, catalogue) {
    var shop = catalogue.shop || {};
    var items = catalogue.items || [];
    if (items.length === 0) {
      showMessage(root, "ai-shop-empty", "This shop has nothing for sale right now.");
      return;
    }

    var uid = root.id || "ai-shop";
    var key = el("input", { type: "hidden", name: "key", value: newKey() });
    var problem = el("p", { class: "ai-shop-form-error", role: "alert", hidden: true });
    var submit = el("button", {
      class: "ai-shop-btn ai-shop-btn--primary ai-shop-btn--block",
      type: "submit",
      text: "Continue to payment",
    });

    var details = [
      field(uid + "-name", "Name", el("input", {
        class: "ai-shop-form-input", id: uid + "-name", name: "name",
        autocomplete: "name", required: true, maxlength: 100,
      })),
      field(uid + "-contact", "Email or phone", el("input", {
        class: "ai-shop-form-input", id: uid + "-contact", name: "contact",
        autocomplete: "email", required: true, maxlength: 254,
      }), "for your receipt and order updates"),
    ];
    if (shop.instalments) {
      var hint = "optional. Leave empty to pay in full";
      if (shop.min_deposit_percent) hint += "; at least " + shop.min_deposit_percent + "% of the order";
      details.push(field(uid + "-deposit", "Pay now (" + shop.currency + ")", el("input", {
        class: "ai-shop-form-input", id: uid + "-deposit", name: "deposit", inputmode: "decimal",
      }), hint));
    }

    // A plain form post: the browser follows checkout's redirect to the
    // payment page, or shows the shop's page with what needs fixing.
    var form = el("form", {
      class: "ai-shop-form",
      method: "post",
      action: checkoutAction(config.apiUrl, shop.checkout_url || ""),
      target: "_top",
      novalidate: true,
    }, [
      key,
      el("div", { class: "ai-shop-grid" }, items.map(function (item) { return renderItem(item, config); })),
      el("section", { class: "ai-shop-checkout-section" }, [
        el("h3", { class: "ai-shop-checkout-section-title", text: "Your details" }),
      ].concat(details, [problem, submit])),
    ]);

    form.addEventListener("submit", function (event) {
      var chosen = 0;
      var valid = true;
      Array.prototype.forEach.call(form.elements, function (input) {
        if (!input.name || input.name.indexOf(QTY_PREFIX) !== 0 || input.value === "") return;
        var quantity = Number(input.value);
        if (!Number.isInteger(quantity) || quantity < 0 || quantity > MAX_QUANTITY) valid = false;
        else chosen += quantity;
      });
      var message = "";
      if (!valid) message = "Quantities must be whole numbers between 0 and " + MAX_QUANTITY + ".";
      else if (chosen === 0) message = "Choose at least one item.";
      else if (!form.reportValidity()) message = "Enter your name and an email address or phone number.";
      if (message) {
        event.preventDefault();
        problem.textContent = message;
        problem.hidden = false;
        return;
      }
      problem.hidden = true;
      submit.disabled = true; // one order per click
    });

    // Back from the payment page: the form may be sent again as a new order.
    window.addEventListener("pageshow", function (event) {
      if (!event.persisted) return;
      key.value = newKey();
      submit.disabled = false;
    });

    root.replaceChildren(
      el("div", { class: "ai-shop-grid-header" }, [
        el("h2", { class: "ai-shop-grid-title", text: shop.name || "" }),
        shop.description ? el("p", { class: "ai-shop-detail-description", text: shop.description }) : null,
      ]),
      form
    );
  }

  function mount(root) {
    var config;
    try {
      config = JSON.parse(root.getAttribute("data-config") || "{}");
    } catch (e) {
      config = {};
    }
    if (!config.apiUrl || !config.slug) {
      showMessage(root, "ai-shop-error", "This shop is not set up: it needs apiUrl and slug.");
      return;
    }
    root.replaceChildren(el("div", { class: "ai-shop-loading" }, [
      el("div", { class: "ai-shop-spinner", "aria-hidden": "true" }),
      el("p", { class: "ai-shop-loading-text", text: "Loading the shop" }),
    ]));

    var url = trimSlash(config.apiUrl) + "/shop/" + encodeURIComponent(config.slug) + "/catalogue";
    fetch(url, { credentials: "omit", headers: { Accept: "application/json" } })
      .then(function (resp) {
        if (resp.status === 404) throw new Error("This shop is not available.");
        if (resp.status === 429) throw new Error("Too many visits just now. Please try again in a minute.");
        if (!resp.ok) throw new Error("This shop could not be loaded just now. Please try again shortly.");
        return resp.json();
      })
      .then(function (catalogue) { render(root, config, catalogue); })
      .catch(function (err) {
        showMessage(root, "ai-shop-error", err && err.message ? err.message : "This shop could not be loaded.");
      });
  }

  function init() {
    Array.prototype.forEach.call(document.querySelectorAll(".ai-shop-widget[data-config]"), mount);
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
