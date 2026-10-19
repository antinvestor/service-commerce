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

(function () {
  "use strict";

  // ============================================================
  // 1. API Client — thin fetch() wrapper for Connect-RPC JSON
  // ============================================================

  function createApiClient(baseUrl, token) {
    var headers = {
      "Content-Type": "application/json",
      "Connect-Protocol-Version": "1",
    };
    if (token) {
      headers["Authorization"] = "Bearer " + token;
    }

    function rpc(service, method, body) {
      var url = baseUrl.replace(/\/+$/, "") + "/" + service + "/" + method;
      return fetch(url, {
        method: "POST",
        headers: headers,
        body: JSON.stringify(body || {}),
      }).then(function (resp) {
        return resp.json().then(function (data) {
          if (!resp.ok || data.code) {
            var msg = (data && data.message) || "Request failed";
            var err = new Error(msg);
            err.code = data.code || "unknown";
            throw err;
          }
          return data;
        });
      });
    }

    function commerce(method, body) {
      return rpc("commerce.v1.CommerceService", method, body);
    }

    return {
      getProduct: function (id) {
        return commerce("GetProduct", { id: id });
      },
      listProducts: function (shopId) {
        return commerce("ListProducts", { shopId: shopId });
      },
      listProductVariants: function (productId) {
        return commerce("ListProductVariants", { productId: productId });
      },
      createCart: function (shopId, profileId) {
        return commerce("CreateCart", {
          shopId: shopId,
          profileId: profileId,
        });
      },
      addCartLine: function (cartId, variantId, quantity) {
        return commerce("AddCartLine", {
          cartId: cartId,
          productVariantId: variantId,
          quantity: quantity,
        });
      },
      removeCartLine: function (cartId, cartLineId) {
        return commerce("RemoveCartLine", {
          cartId: cartId,
          cartLineId: cartLineId,
        });
      },
      createOrder: function (shopId, profileId, lines) {
        return commerce("CreateOrder", {
          shopId: shopId,
          profileId: profileId,
          lines: lines,
        });
      },
      getOrder: function (id) {
        return commerce("GetOrder", { id: id });
      },
      // amount is optional: omitted, the checkout charges the whole balance.
      checkoutOrder: function (orderId, returnUrl, amount) {
        var body = { orderId: orderId };
        if (returnUrl) body.returnUrl = returnUrl;
        if (amount) body.amount = amount;
        return commerce("CheckoutOrder", body);
      },
      createOrderFromCart: function (cartId, profileId, addressId) {
        var body = { cartId: cartId, profileId: profileId };
        if (addressId) body.addressId = addressId;
        return commerce("CreateOrderFromCart", body);
      },
    };
  }

  function createProfileClient(baseUrl, token) {
    var headers = {
      "Content-Type": "application/json",
      "Connect-Protocol-Version": "1",
    };
    if (token) {
      headers["Authorization"] = "Bearer " + token;
    }

    function rpc(method, body) {
      var url =
        baseUrl.replace(/\/+$/, "") +
        "/profile.v1.ProfileService/" +
        method;
      return fetch(url, {
        method: "POST",
        headers: headers,
        body: JSON.stringify(body || {}),
      }).then(function (resp) {
        return resp.json().then(function (data) {
          if (!resp.ok || data.code) {
            var msg = (data && data.message) || "Request failed";
            var err = new Error(msg);
            err.code = data.code || "unknown";
            throw err;
          }
          return data;
        });
      });
    }

    return {
      getById: function (id) {
        return rpc("GetById", { id: id });
      },
      addAddress: function (profileId, address) {
        return rpc("AddAddress", {
          profileId: profileId,
          address: address,
        });
      },
    };
  }

  // ============================================================
  // 2. State Store — plain object with setState/subscribe
  // ============================================================

  function createStore(initial) {
    var state = Object.assign(
      {
        screen: "loading",
        products: {},
        variants: {},
        selectedProduct: null,
        selectedVariant: null,
        quantity: 1,
        cart: null,
        cartItems: [],
        cartOpen: false,
        profile: null,
        addresses: [],
        selectedAddressId: null,
        showAddressForm: false,
        addressErrors: {},
        error: null,
        toastMessage: null,
        toastType: "error",
        // Order being paid (pay screen) or shown after checkout (order screen).
        order: null,
        payMode: "full",
        payAmountInput: "",
        payError: null,
      },
      initial || {}
    );

    var listeners = [];

    return {
      get: function () {
        return state;
      },
      // patch updates state without re-rendering, for values typed into
      // inputs that a re-render would otherwise wipe.
      patch: function (partial) {
        state = Object.assign({}, state, partial);
      },
      setState: function (partial) {
        state = Object.assign({}, state, partial);
        for (var i = 0; i < listeners.length; i++) {
          listeners[i](state);
        }
      },
      subscribe: function (fn) {
        listeners.push(fn);
        return function () {
          listeners = listeners.filter(function (l) {
            return l !== fn;
          });
        };
      },
    };
  }

  // ============================================================
  // 3. Helpers
  // ============================================================

  var FULFILMENT_TYPE_UNSPECIFIED = 0;
  var FULFILMENT_TYPE_PHYSICAL = 1;
  var FULFILMENT_TYPE_DIGITAL = 2;
  var FULFILMENT_TYPE_NONE = 3;

  // --- Money ---
  // Money travels as {currencyCode, units: "int64 string", nanos: int}.
  // Arithmetic is done in integer minor units (cents for most currencies)
  // so totals never accumulate floating-point error.

  var POW10 = [1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000];

  // currencyDigits returns how many minor-unit digits a currency uses
  // (2 for USD/KES, 0 for JPY, 3 for KWD), defaulting to 2.
  function currencyDigits(currency) {
    if (!currency) return 2;
    try {
      var d = new Intl.NumberFormat("en", { style: "currency", currency: currency })
        .resolvedOptions().maximumFractionDigits;
      return d >= 0 && d <= 9 ? d : 2;
    } catch (e) {
      return 2;
    }
  }

  // moneyToMinor converts a Money to an integer count of minor units,
  // rounding up any sub-minor remainder so a limit is never undershot.
  function moneyToMinor(moneyObj, digits) {
    if (!moneyObj) return 0;
    if (digits === undefined) digits = currencyDigits(moneyObj.currencyCode);
    var units = parseInt(moneyObj.units || "0", 10) || 0;
    var nanos = parseInt(moneyObj.nanos || "0", 10) || 0;
    var step = POW10[9 - digits];
    var frac = nanos / step;
    frac = nanos >= 0 ? Math.ceil(frac) : Math.floor(frac);
    return units * POW10[digits] + frac;
  }

  // minorToMoney converts integer minor units back to a Money message.
  function minorToMoney(minor, currency, digits) {
    if (digits === undefined) digits = currencyDigits(currency);
    var scale = POW10[digits];
    var rem = minor % scale; // keeps the sign of minor, as Money requires
    var units = (minor - rem) / scale;
    return {
      currencyCode: currency || "",
      units: String(units),
      nanos: rem * POW10[9 - digits],
    };
  }

  // minorToDecimal renders minor units as a plain decimal string ("1234.50").
  function minorToDecimal(minor, digits) {
    var neg = minor < 0;
    var abs = String(Math.abs(minor));
    if (digits > 0) {
      while (abs.length <= digits) abs = "0" + abs;
      abs = abs.slice(0, abs.length - digits) + "." + abs.slice(abs.length - digits);
    }
    return (neg ? "-" : "") + abs;
  }

  // parseDecimalToMinor parses user input like "1,234.5" into minor units,
  // returning null when it is not a valid non-negative amount.
  function parseDecimalToMinor(str, digits) {
    if (str === null || str === undefined) return null;
    var clean = String(str).replace(/[\s,]/g, "");
    var m = /^(\d*)(?:\.(\d*))?$/.exec(clean);
    if (!m || (!m[1] && !m[2])) return null;
    var frac = m[2] || "";
    if (frac.length > digits) return null;
    while (frac.length < digits) frac += "0";
    return parseInt(m[1] || "0", 10) * POW10[digits] + (digits ? parseInt(frac, 10) : 0);
  }

  function formatMinor(minor, currency, digits) {
    if (digits === undefined) digits = currencyDigits(currency);
    try {
      return new Intl.NumberFormat(undefined, {
        style: "currency",
        currency: currency,
        minimumFractionDigits: digits,
        maximumFractionDigits: digits,
      }).format(minor / POW10[digits]);
    } catch (e) {
      return (currency ? currency + " " : "") + minorToDecimal(minor, digits);
    }
  }

  function formatMoney(moneyObj) {
    if (!moneyObj) return "";
    var currency = moneyObj.currencyCode || "";
    var digits = currencyDigits(currency);
    return formatMinor(moneyToMinor(moneyObj, digits), currency, digits);
  }

  // ceilPercent returns ceil(minor * percent / 100) using integers only.
  function ceilPercent(minor, percent) {
    var p = minor * percent;
    var q = (p - (p % 100)) / 100;
    return p % 100 > 0 ? q + 1 : q;
  }

  // --- Payment policy ---

  var PAYMENT_STATUS = {
    0: "PAYMENT_STATUS_UNSPECIFIED",
    1: "PAYMENT_STATUS_PENDING",
    2: "PAYMENT_STATUS_PAID",
    3: "PAYMENT_STATUS_FAILED",
    4: "PAYMENT_STATUS_REFUNDED",
    5: "PAYMENT_STATUS_EXPIRED",
    6: "PAYMENT_STATUS_PARTIALLY_PAID",
  };

  function paymentStatusOf(order) {
    var ps = order && order.paymentStatus;
    if (ps === undefined || ps === null) return "PAYMENT_STATUS_UNSPECIFIED";
    if (typeof ps === "number" || /^\d+$/.test(ps)) {
      return PAYMENT_STATUS[parseInt(ps, 10)] || "PAYMENT_STATUS_UNSPECIFIED";
    }
    return ps;
  }

  // orderPaymentState derives what the buyer can pay on an order, all in
  // integer minor units. minMinor is the smallest instalment the policy
  // accepts right now (deposit if nothing is paid yet, else instalment);
  // any amount from minMinor up to balanceMinor is valid, and the whole
  // balance always is.
  function orderPaymentState(order) {
    var total = (order && order.total) || {};
    var currency = total.currencyCode ||
      (order && order.balance && order.balance.currencyCode) || "";
    var digits = currencyDigits(currency);
    var totalMinor = moneyToMinor(total, digits);
    var paidMinor = moneyToMinor(order && order.amountPaid, digits);
    var balanceMinor = order && order.balance
      ? moneyToMinor(order.balance, digits)
      : Math.max(0, totalMinor - paidMinor);
    var policy = (order && order.paymentPolicy) || {};
    var percent = paidMinor > 0
      ? parseInt(policy.minInstalmentPercent || 0, 10) || 0
      : parseInt(policy.minDepositPercent || 0, 10) || 0;
    var minMinor = Math.max(1, ceilPercent(totalMinor, percent));
    if (minMinor > balanceMinor) minMinor = balanceMinor;
    return {
      currency: currency,
      digits: digits,
      totalMinor: totalMinor,
      paidMinor: paidMinor,
      balanceMinor: balanceMinor,
      minMinor: minMinor,
      minPercent: percent,
      isDeposit: paidMinor === 0,
      // A part payment only makes sense when the minimum is below the balance.
      allowInstalments: !!policy.allowInstalments && balanceMinor > 0 && minMinor < balanceMinor,
      balanceDueAt: (order && order.balanceDueAt) || "",
    };
  }

  // validateInstalment checks a typed amount against the payment state.
  // Returns {minor} on success or {error} with a buyer-facing message.
  function validateInstalment(input, ps) {
    var minor = parseDecimalToMinor(input, ps.digits);
    if (minor === null || minor <= 0) {
      return { error: "Enter a valid amount" };
    }
    if (minor > ps.balanceMinor) {
      return { error: "Amount cannot exceed the balance of " + formatMinor(ps.balanceMinor, ps.currency, ps.digits) };
    }
    if (minor < ps.minMinor) {
      return {
        error: "Minimum " + (ps.isDeposit ? "deposit" : "instalment") + " is " +
          formatMinor(ps.minMinor, ps.currency, ps.digits),
      };
    }
    return { minor: minor };
  }

  function formatDate(ts) {
    if (!ts) return "";
    var d = new Date(ts);
    if (isNaN(d.getTime())) return "";
    try {
      return d.toLocaleDateString(undefined, { year: "numeric", month: "short", day: "numeric" });
    } catch (e) {
      return d.toDateString();
    }
  }

  function parseJwtSub(token) {
    if (!token) return null;
    try {
      var parts = token.split(".");
      if (parts.length < 2) return null;
      var payload = JSON.parse(atob(parts[1]));
      return payload.sub || null;
    } catch (e) {
      return null;
    }
  }

  function escapeHtml(str) {
    if (!str) return "";
    var div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  }

  function mediaUrl(baseUrl, id) {
    if (!baseUrl || !id) return "";
    return baseUrl.replace(/\/+$/, "") + "/" + id;
  }

  function getFulfilmentType(product) {
    if (!product) return FULFILMENT_TYPE_UNSPECIFIED;
    var ft = product.fulfilmentType;
    if (typeof ft === "string") {
      if (ft === "FULFILMENT_TYPE_PHYSICAL" || ft === "1") return FULFILMENT_TYPE_PHYSICAL;
      if (ft === "FULFILMENT_TYPE_DIGITAL" || ft === "2") return FULFILMENT_TYPE_DIGITAL;
      if (ft === "FULFILMENT_TYPE_NONE" || ft === "3") return FULFILMENT_TYPE_NONE;
      return FULFILMENT_TYPE_UNSPECIFIED;
    }
    return parseInt(ft, 10) || FULFILMENT_TYPE_UNSPECIFIED;
  }

  function isOutOfStock(variant) {
    if (!variant) return true;
    return (parseInt(variant.stockQuantity, 10) || 0) <= 0;
  }

  // ============================================================
  // 4. Action Dispatcher
  // ============================================================

  function createDispatcher(store, api, profileApi, config) {
    var shopId = config.shopId;
    var profileId = config.profileId || parseJwtSub(config.token);
    var mediaBase = config.mediaBaseUrl;
    var paymentUrl = config.paymentUrl;

    // returnUrlFor is where the hosted checkout sends the buyer back to: the
    // configured paymentUrl, else this page, tagged with the order id so the
    // widget can show the order's payment status on return.
    function returnUrlFor(order) {
      var base = paymentUrl || (typeof window !== "undefined" ? window.location.href : "");
      if (!base) return undefined;
      try {
        var u = new URL(base, window.location.href);
        u.searchParams.set("order_id", order.id);
        return u.toString();
      } catch (e) {
        return base;
      }
    }

    function orderIdFromUrl() {
      try {
        return new URLSearchParams(window.location.search).get("order_id") || "";
      } catch (e) {
        return "";
      }
    }

    function clearOrderIdFromUrl() {
      try {
        var u = new URL(window.location.href);
        if (!u.searchParams.has("order_id")) return;
        u.searchParams.delete("order_id");
        window.history.replaceState(null, "", u.toString());
      } catch (e) {
        /* ignore */
      }
    }

    // startPayment continues from a freshly placed order. When the order's
    // policy allows instalments the buyer chooses how much to pay now;
    // otherwise they go straight to the hosted checkout for the full amount.
    function startPayment(order) {
      if (!order) {
        showToast("Order placed successfully!", "success");
        dispatch("INIT");
        return null;
      }
      var ps = orderPaymentState(order);
      if (ps.allowInstalments) {
        openPayScreen(order);
        return null;
      }
      return redirectToCheckout(order, null);
    }

    function openPayScreen(order) {
      var ps = orderPaymentState(order);
      store.setState({
        order: order,
        screen: "pay",
        payMode: "full",
        payAmountInput: minorToDecimal(ps.minPercent > 0 ? ps.minMinor : ps.balanceMinor, ps.digits),
        payError: null,
      });
    }

    // redirectToCheckout creates the hosted checkout session for amount
    // (a Money, or null for the whole balance) and sends the buyer to it.
    function redirectToCheckout(order, amount) {
      store.setState({ screen: "loading" });
      return api
        .checkoutOrder(order.id, returnUrlFor(order), amount || undefined)
        .then(function (r) {
          if (r.checkoutUrl) {
            window.location.href = r.checkoutUrl;
            return null;
          }
          showToast("Order " + (order.orderNumber || "") + " placed. Payment is pending.", "success");
          store.setState({ order: r.order || order, screen: "order" });
          return null;
        })
        .catch(function (err) {
          showToast(err.message || "Could not start payment. Try again from your order.");
          store.setState({ order: order, screen: "order" });
        });
    }

    function showToast(msg, type) {
      store.setState({ toastMessage: msg, toastType: type || "error" });
      setTimeout(function () {
        store.setState({ toastMessage: null });
      }, 4000);
    }

    function enrichCartItems() {
      var s = store.get();
      var cart = s.cart;
      if (!cart || !cart.lines) {
        store.setState({ cartItems: [] });
        return;
      }
      var items = cart.lines.map(function (line) {
        var variantId = line.productVariantId;
        var variant = null;
        // Search all cached variants
        var vKeys = Object.keys(s.variants);
        for (var i = 0; i < vKeys.length; i++) {
          var variantsForProduct = s.variants[vKeys[i]];
          for (var j = 0; j < variantsForProduct.length; j++) {
            if (variantsForProduct[j].id === variantId) {
              variant = variantsForProduct[j];
              break;
            }
          }
          if (variant) break;
        }
        return {
          lineId: line.id,
          variantId: variantId,
          quantity: parseInt(line.quantity, 10) || 0,
          variantName: variant ? variant.name : "Item",
          productName: variant ? (s.products[variant.productId] || {}).name || "" : "",
          price: variant ? variant.price : null,
        };
      });
      store.setState({ cartItems: items });
    }

    function computeCartTotal() {
      var items = store.get().cartItems;
      var currency = "";
      items.forEach(function (item) {
        if (item.price && item.price.currencyCode) currency = currency || item.price.currencyCode;
      });
      var digits = currencyDigits(currency);
      var totalMinor = 0;
      items.forEach(function (item) {
        if (item.price) totalMinor += moneyToMinor(item.price, digits) * item.quantity;
      });
      return minorToMoney(totalMinor, currency, digits);
    }

    var dispatch = function (action, payload) {
      var s = store.get();

      switch (action) {
        case "INIT":
          var returnedOrderId = orderIdFromUrl();
          if (returnedOrderId && !payload) {
            dispatch("LOAD_ORDER", { orderId: returnedOrderId });
            break;
          }
          var productIdStr = config.productIds || "";
          var productIds = productIdStr
            .split(",")
            .map(function (s) { return s.trim(); })
            .filter(Boolean);

          if (productIds.length === 1) {
            dispatch("SELECT_PRODUCT", { productId: productIds[0] });
          } else if (productIds.length > 1) {
            store.setState({ screen: "loading" });
            Promise.all(
              productIds.map(function (id) {
                return api.getProduct(id);
              })
            )
              .then(function (results) {
                var products = {};
                results.forEach(function (r) {
                  if (r.product) products[r.product.id] = r.product;
                });
                store.setState({ products: products, screen: "grid" });
              })
              .catch(function (err) {
                store.setState({
                  screen: "error",
                  error: err.message || "Failed to load products",
                });
              });
          } else if (shopId) {
            store.setState({ screen: "loading" });
            api
              .listProducts(shopId)
              .then(function (r) {
                var products = {};
                (r.products || []).forEach(function (p) {
                  products[p.id] = p;
                });
                var keys = Object.keys(products);
                if (keys.length === 1) {
                  store.setState({ products: products });
                  dispatch("SELECT_PRODUCT", { productId: keys[0] });
                } else {
                  store.setState({ products: products, screen: "grid" });
                }
              })
              .catch(function (err) {
                store.setState({
                  screen: "error",
                  error: err.message || "Failed to load products",
                });
              });
          } else {
            store.setState({
              screen: "error",
              error: "No shop ID or product IDs provided",
            });
          }
          break;

        case "SELECT_PRODUCT":
          store.setState({ screen: "loading" });
          var pid = payload.productId;
          var cached = s.products[pid];

          var fetchProduct = cached
            ? Promise.resolve(cached)
            : api.getProduct(pid).then(function (r) {
                return r.product;
              });

          fetchProduct
            .then(function (product) {
              var products = Object.assign({}, s.products);
              products[product.id] = product;
              store.setState({ products: products, selectedProduct: product });
              return api.listProductVariants(product.id);
            })
            .then(function (r) {
              var variants = Object.assign({}, store.get().variants);
              var vList = r.productVariants || [];
              variants[pid] = vList;
              var selectedVariant = vList.length > 0 ? vList[0] : null;
              store.setState({
                variants: variants,
                selectedVariant: selectedVariant,
                quantity: 1,
                screen: "detail",
              });
            })
            .catch(function (err) {
              store.setState({
                screen: "error",
                error: err.message || "Failed to load product",
              });
            });
          break;

        case "SELECT_VARIANT":
          store.setState({ selectedVariant: payload.variant, quantity: 1 });
          break;

        case "SET_QUANTITY":
          var maxQty = s.selectedVariant
            ? parseInt(s.selectedVariant.stockQuantity, 10) || 0
            : 1;
          var qty = Math.max(1, Math.min(parseInt(payload.quantity, 10) || 1, maxQty));
          store.setState({ quantity: qty });
          break;

        case "ADD_TO_CART":
          if (!s.selectedVariant) return;
          var variant = s.selectedVariant;
          var cartPromise;
          if (s.cart && s.cart.id) {
            cartPromise = Promise.resolve(s.cart);
          } else {
            cartPromise = api
              .createCart(shopId, profileId)
              .then(function (r) {
                return r.cart;
              });
          }
          cartPromise
            .then(function (cart) {
              store.setState({ cart: cart });
              return api.addCartLine(cart.id, variant.id, s.quantity);
            })
            .then(function (r) {
              store.setState({ cart: r.cart, cartOpen: true });
              enrichCartItems();
              showToast("Added to cart", "success");
            })
            .catch(function (err) {
              showToast(err.message || "Failed to add to cart");
            });
          break;

        case "REMOVE_FROM_CART":
          if (!s.cart) return;
          api
            .removeCartLine(s.cart.id, payload.cartLineId)
            .then(function (r) {
              store.setState({ cart: r.cart });
              enrichCartItems();
            })
            .catch(function (err) {
              showToast(err.message || "Failed to remove item");
            });
          break;

        case "TOGGLE_CART":
          store.setState({ cartOpen: !s.cartOpen });
          break;

        case "START_CHECKOUT":
          if (!s.cart || !s.cartItems.length) return;
          store.setState({ screen: "loading" });

          var needsAddress = false;
          var cartItems = s.cartItems;
          for (var i = 0; i < cartItems.length; i++) {
            var cVariant = null;
            var vKeys = Object.keys(s.variants);
            for (var vi = 0; vi < vKeys.length; vi++) {
              var vs = s.variants[vKeys[vi]];
              for (var vj = 0; vj < vs.length; vj++) {
                if (vs[vj].id === cartItems[i].variantId) {
                  cVariant = vs[vj];
                  break;
                }
              }
              if (cVariant) break;
            }
            if (cVariant) {
              var product = s.products[cVariant.productId];
              if (product && getFulfilmentType(product) === FULFILMENT_TYPE_PHYSICAL) {
                needsAddress = true;
                break;
              }
            }
          }

          if (needsAddress && profileApi && profileId) {
            profileApi
              .getById(profileId)
              .then(function (r) {
                var profile = r.profile || r;
                var addresses = profile.addresses || [];
                store.setState({
                  profile: profile,
                  addresses: addresses,
                  selectedAddressId: addresses.length > 0 ? addresses[0].id : null,
                  showAddressForm: addresses.length === 0,
                  cartOpen: false,
                  screen: "checkout",
                });
              })
              .catch(function (err) {
                store.setState({
                  cartOpen: false,
                  screen: "checkout",
                  addresses: [],
                  showAddressForm: true,
                });
              });
          } else {
            store.setState({ cartOpen: false, screen: "checkout" });
          }
          break;

        case "SELECT_ADDRESS":
          store.setState({
            selectedAddressId: payload.addressId,
            showAddressForm: false,
          });
          break;

        case "SHOW_ADDRESS_FORM":
          store.setState({ showAddressForm: true, addressErrors: {} });
          break;

        case "ADD_ADDRESS":
          if (!profileApi || !profileId) {
            showToast("Profile service not configured");
            return;
          }
          var addr = payload.address;
          var errors = {};
          if (!addr.name) errors.name = "Required";
          if (!addr.country) errors.country = "Required";
          if (!addr.city) errors.city = "Required";
          if (Object.keys(errors).length) {
            store.setState({ addressErrors: errors });
            return;
          }
          store.setState({ addressErrors: {} });
          profileApi
            .addAddress(profileId, addr)
            .then(function (r) {
              var newAddr = r.address || r;
              var addresses = s.addresses.concat([newAddr]);
              store.setState({
                addresses: addresses,
                selectedAddressId: newAddr.id,
                showAddressForm: false,
              });
              showToast("Address saved", "success");
            })
            .catch(function (err) {
              showToast(err.message || "Failed to save address");
            });
          break;

        case "PLACE_ORDER":
          if (!s.cart) return;

          var hasPhysical = false;
          s.cartItems.forEach(function (item) {
            var vr = null;
            Object.keys(s.variants).forEach(function (pk) {
              s.variants[pk].forEach(function (v) {
                if (v.id === item.variantId) vr = v;
              });
            });
            if (vr) {
              var p = s.products[vr.productId];
              if (p && getFulfilmentType(p) === FULFILMENT_TYPE_PHYSICAL) hasPhysical = true;
            }
          });

          if (hasPhysical && !s.selectedAddressId) {
            showToast("Please select a delivery address");
            return;
          }

          store.setState({ screen: "loading" });
          api
            .createOrderFromCart(s.cart.id, profileId, s.selectedAddressId)
            .then(function (r) {
              var order = r.order;
              store.setState({
                cart: null,
                cartItems: [],
                cartOpen: false,
              });
              return startPayment(order);
            })
            .catch(function (err) {
              store.setState({ screen: "checkout" });
              showToast(err.message || "Failed to place order");
            });
          break;

        case "IMMEDIATE_ORDER":
          // Buy now goes through a dedicated cart so it uses the buyer's
          // order path (CreateOrder is staff-only) without touching the
          // shopping cart the buyer may already have.
          if (!s.selectedVariant || !s.selectedProduct) return;
          var buyVariant = s.selectedVariant;
          var buyQty = s.quantity;
          store.setState({ screen: "loading" });
          api
            .createCart(shopId, profileId)
            .then(function (r) {
              return api.addCartLine(r.cart.id, buyVariant.id, buyQty);
            })
            .then(function (r) {
              return api.createOrderFromCart(r.cart.id, profileId);
            })
            .then(function (r) {
              return startPayment(r.order);
            })
            .catch(function (err) {
              store.setState({ screen: "detail" });
              showToast(err.message || "Failed to place order");
            });
          break;

        case "LOAD_ORDER":
          store.setState({ screen: "loading" });
          api
            .getOrder(payload.orderId)
            .then(function (r) {
              if (!r.order) throw new Error("Order not found");
              store.setState({ order: r.order, screen: "order" });
            })
            .catch(function (err) {
              store.setState({
                screen: "error",
                error: err.message || "Failed to load order",
              });
            });
          break;

        case "REFRESH_ORDER":
          if (!s.order) return;
          dispatch("LOAD_ORDER", { orderId: s.order.id });
          break;

        case "PAY_ORDER":
          // From the order status card: pay the next instalment or the rest.
          if (!s.order) return;
          if (orderPaymentState(s.order).allowInstalments) {
            openPayScreen(s.order);
          } else {
            redirectToCheckout(s.order, null);
          }
          break;

        case "SET_PAY_MODE":
          store.setState({
            payMode: payload.mode === "part" ? "part" : "full",
            payError: null,
          });
          break;

        case "SUBMIT_PAYMENT":
          if (!s.order) return;
          if (s.payMode !== "part") {
            redirectToCheckout(s.order, null);
            break;
          }
          var pstate = orderPaymentState(s.order);
          var checked = validateInstalment(s.payAmountInput, pstate);
          if (checked.error) {
            store.setState({ payError: checked.error });
            return;
          }
          // Paying the whole balance needs no amount; the server charges it.
          var payAmount = checked.minor === pstate.balanceMinor
            ? null
            : minorToMoney(checked.minor, pstate.currency, pstate.digits);
          redirectToCheckout(s.order, payAmount);
          break;

        case "CONTINUE_SHOPPING":
          clearOrderIdFromUrl();
          store.setState({ order: null, payError: null });
          dispatch("INIT", { fresh: true });
          break;

        case "BACK_TO_GRID":
          store.setState({
            selectedProduct: null,
            selectedVariant: null,
            quantity: 1,
            screen: "grid",
          });
          break;

        case "RETRY":
          dispatch("INIT");
          break;
      }
    };

    dispatch.computeCartTotal = computeCartTotal;
    return dispatch;
  }

  // ============================================================
  // 5. Renderer — HTML string generation + event delegation
  // ============================================================

  function createRenderer(rootEl, store, dispatch, config) {
    var mediaBase = config.mediaBaseUrl;

    function render() {
      var s = store.get();
      var html = "";

      switch (s.screen) {
        case "loading":
          html = renderLoading();
          break;
        case "grid":
          html = renderGrid(s);
          break;
        case "detail":
          html = renderDetail(s);
          break;
        case "checkout":
          html = renderCheckout(s);
          break;
        case "pay":
          html = renderPay(s);
          break;
        case "order":
          html = renderOrderStatus(s);
          break;
        case "error":
          html = renderError(s);
          break;
      }

      html += renderCartSidebar(s);
      html += renderToast(s);

      rootEl.innerHTML = html;
    }

    function renderLoading() {
      return (
        '<div class="ai-shop-loading">' +
        '<div class="ai-shop-spinner"></div>' +
        '<div class="ai-shop-loading-text">Loading...</div>' +
        "</div>"
      );
    }

    function renderError(s) {
      return (
        '<div class="ai-shop-error">' +
        '<div class="ai-shop-error-icon">&#9888;</div>' +
        '<div class="ai-shop-error-message">' +
        escapeHtml(s.error || "Something went wrong") +
        "</div>" +
        '<button class="ai-shop-btn ai-shop-btn--primary" data-action="RETRY">Try Again</button>' +
        "</div>"
      );
    }

    function renderGrid(s) {
      var products = s.products;
      var keys = Object.keys(products);
      var cartCount = s.cartItems.reduce(function (sum, i) { return sum + i.quantity; }, 0);

      var html =
        '<div class="ai-shop-grid">' +
        '<div class="ai-shop-grid-header">' +
        '<h2 class="ai-shop-grid-title">Products</h2>';

      if (s.cart) {
        html +=
          '<button class="ai-shop-cart-toggle" data-action="TOGGLE_CART">' +
          "Cart" +
          (cartCount > 0
            ? ' <span class="ai-shop-cart-badge">' + cartCount + "</span>"
            : "") +
          "</button>";
      }

      html += "</div>";

      keys.forEach(function (id) {
        var product = products[id];
        var imgId =
          product.mediaIds && product.mediaIds.length > 0
            ? product.mediaIds[0]
            : null;
        var imgHtml = imgId
          ? '<img class="ai-shop-card-image" src="' +
            escapeHtml(mediaUrl(mediaBase, imgId)) +
            '" alt="' +
            escapeHtml(product.name) +
            '" loading="lazy">'
          : '<div class="ai-shop-card-placeholder">&#128722;</div>';

        html +=
          '<div class="ai-shop-card" data-action="SELECT_PRODUCT" data-payload=\'' +
          escapeHtml(JSON.stringify({ productId: id })) +
          "'>" +
          imgHtml +
          '<div class="ai-shop-card-body">' +
          '<div class="ai-shop-card-name">' +
          escapeHtml(product.name) +
          "</div>" +
          "</div>" +
          "</div>";
      });

      html += "</div>";
      return html;
    }

    function renderDetail(s) {
      var product = s.selectedProduct;
      if (!product) return renderError({ error: "Product not found" });

      var variant = s.selectedVariant;
      var variantsList = s.variants[product.id] || [];
      var ft = getFulfilmentType(product);
      var multipleProducts = Object.keys(s.products).length > 1;
      var cartCount = s.cartItems.reduce(function (sum, i) { return sum + i.quantity; }, 0);

      var imgId =
        product.mediaIds && product.mediaIds.length > 0
          ? product.mediaIds[0]
          : null;
      var imgHtml = imgId
        ? '<img class="ai-shop-detail-image" src="' +
          escapeHtml(mediaUrl(mediaBase, imgId)) +
          '" alt="' +
          escapeHtml(product.name) +
          '">'
        : '<div class="ai-shop-detail-placeholder">&#128722;</div>';

      var html = '<div class="ai-shop-detail">';

      // Back button + cart toggle
      if (multipleProducts || s.cart) {
        html += '<div class="ai-shop-detail-back" style="display:flex;justify-content:space-between;align-items:center;">';
        if (multipleProducts) {
          html +=
            '<button class="ai-shop-btn ai-shop-btn--outline ai-shop-btn--sm" data-action="BACK_TO_GRID">' +
            "&larr; Back" +
            "</button>";
        } else {
          html += "<span></span>";
        }
        if (s.cart) {
          html +=
            '<button class="ai-shop-cart-toggle" data-action="TOGGLE_CART">' +
            "Cart" +
            (cartCount > 0
              ? ' <span class="ai-shop-cart-badge">' + cartCount + "</span>"
              : "") +
            "</button>";
        }
        html += "</div>";
      }

      // Image
      html += "<div>" + imgHtml + "</div>";

      // Info
      html += '<div class="ai-shop-detail-info">';
      html +=
        '<h1 class="ai-shop-detail-name">' +
        escapeHtml(product.name) +
        "</h1>";

      if (product.description) {
        html +=
          '<p class="ai-shop-detail-description">' +
          escapeHtml(product.description) +
          "</p>";
      }

      // Price
      if (variant && variant.price) {
        html +=
          '<div class="ai-shop-detail-price">' +
          formatMoney(variant.price) +
          "</div>";
      }

      // Variants selector
      if (variantsList.length > 1) {
        html += '<div class="ai-shop-variants">';
        html += '<div class="ai-shop-variants-label">Options</div>';
        html += '<div class="ai-shop-variants-list">';
        variantsList.forEach(function (v) {
          var selected = variant && variant.id === v.id;
          var oos = isOutOfStock(v);
          html +=
            '<button class="ai-shop-variant-btn' +
            (selected ? " ai-shop-variant-btn--selected" : "") +
            '"' +
            (oos ? " disabled" : "") +
            " data-action=\"SELECT_VARIANT\" data-payload='" +
            escapeHtml(JSON.stringify({ variantId: v.id })) +
            "'>" +
            escapeHtml(v.name) +
            (oos ? " (Out of Stock)" : "") +
            "</button>";
        });
        html += "</div></div>";
      }

      // Stock / Out of stock
      if (variant) {
        if (isOutOfStock(variant)) {
          html += '<div><span class="ai-shop-out-of-stock">Out of Stock</span></div>';
        } else {
          // Quantity selector (for non-NONE types)
          if (ft !== FULFILMENT_TYPE_NONE) {
            var maxQty = parseInt(variant.stockQuantity, 10) || 0;
            html += '<div class="ai-shop-quantity">';
            html += '<span class="ai-shop-quantity-label">Qty</span>';
            html +=
              '<button class="ai-shop-quantity-btn" data-action="SET_QUANTITY" data-payload=\'' +
              JSON.stringify({ quantity: s.quantity - 1 }) +
              "'" +
              (s.quantity <= 1 ? " disabled" : "") +
              ">&minus;</button>";
            html +=
              '<span class="ai-shop-quantity-value">' + s.quantity + "</span>";
            html +=
              '<button class="ai-shop-quantity-btn" data-action="SET_QUANTITY" data-payload=\'' +
              JSON.stringify({ quantity: s.quantity + 1 }) +
              "'" +
              (s.quantity >= maxQty ? " disabled" : "") +
              ">+</button>";
            html += "</div>";
          }

          // Action button
          if (ft === FULFILMENT_TYPE_NONE) {
            html +=
              '<button class="ai-shop-btn ai-shop-btn--primary ai-shop-btn--block" data-action="IMMEDIATE_ORDER">' +
              "Buy Now" +
              "</button>";
          } else {
            html +=
              '<button class="ai-shop-btn ai-shop-btn--primary ai-shop-btn--block" data-action="ADD_TO_CART">' +
              "Add to Cart" +
              "</button>";
          }
        }
      }

      html += "</div>"; // detail-info
      html += "</div>"; // detail
      return html;
    }

    function renderCartSidebar(s) {
      var open = s.cartOpen;
      var items = s.cartItems;
      var total = dispatch.computeCartTotal();

      var html =
        '<div class="ai-shop-cart-overlay' +
        (open ? " ai-shop-cart-overlay--open" : "") +
        '" data-action="TOGGLE_CART"></div>';

      html +=
        '<div class="ai-shop-cart-sidebar' +
        (open ? " ai-shop-cart-sidebar--open" : "") +
        '">';

      // Header
      html +=
        '<div class="ai-shop-cart-header">' +
        '<h3 class="ai-shop-cart-title">Your Cart</h3>' +
        '<button class="ai-shop-cart-close" data-action="TOGGLE_CART">&times;</button>' +
        "</div>";

      // Items
      html += '<div class="ai-shop-cart-items">';
      if (!items.length) {
        html +=
          '<div class="ai-shop-cart-empty">Your cart is empty</div>';
      } else {
        items.forEach(function (item) {
          html += '<div class="ai-shop-cart-item">';
          html += '<div class="ai-shop-cart-item-info">';
          html +=
            '<div class="ai-shop-cart-item-name">' +
            escapeHtml(item.productName) +
            "</div>";
          html +=
            '<div class="ai-shop-cart-item-variant">' +
            escapeHtml(item.variantName) +
            "</div>";
          html +=
            '<div class="ai-shop-cart-item-qty">Qty: ' +
            item.quantity +
            "</div>";
          html +=
            '<button class="ai-shop-cart-item-remove" data-action="REMOVE_FROM_CART" data-payload=\'' +
            escapeHtml(JSON.stringify({ cartLineId: item.lineId })) +
            "'>Remove</button>";
          html += "</div>"; // info
          html +=
            '<div class="ai-shop-cart-item-price">' +
            formatMoney(item.price) +
            "</div>";
          html += "</div>"; // item
        });
      }
      html += "</div>"; // items

      // Footer
      if (items.length) {
        html += '<div class="ai-shop-cart-footer">';
        html +=
          '<div class="ai-shop-cart-total">' +
          "<span>Total</span>" +
          "<span>" +
          formatMoney(total) +
          "</span>" +
          "</div>";
        html +=
          '<button class="ai-shop-btn ai-shop-btn--primary ai-shop-btn--block" data-action="START_CHECKOUT">' +
          "Checkout" +
          "</button>";
        html += "</div>";
      }

      html += "</div>"; // sidebar
      return html;
    }

    function renderCheckout(s) {
      var items = s.cartItems;
      var total = dispatch.computeCartTotal();

      var needsAddress = false;
      items.forEach(function (item) {
        Object.keys(s.variants).forEach(function (pk) {
          s.variants[pk].forEach(function (v) {
            if (v.id === item.variantId) {
              var p = s.products[v.productId];
              if (p && getFulfilmentType(p) === FULFILMENT_TYPE_PHYSICAL) needsAddress = true;
            }
          });
        });
      });

      var html = '<div class="ai-shop-checkout">';

      html +=
        '<div class="ai-shop-checkout-header" style="display:flex;justify-content:space-between;align-items:center;">' +
        '<h2 class="ai-shop-checkout-title">Checkout</h2>' +
        '<button class="ai-shop-btn ai-shop-btn--outline ai-shop-btn--sm" data-action="TOGGLE_CART">' +
        "&larr; Back to Cart" +
        "</button>" +
        "</div>";

      // Order summary
      html += '<div class="ai-shop-checkout-section">';
      html +=
        '<h3 class="ai-shop-checkout-section-title">Order Summary</h3>';
      items.forEach(function (item) {
        html +=
          '<div class="ai-shop-order-summary-item">' +
          "<span>" +
          escapeHtml(item.productName) +
          " - " +
          escapeHtml(item.variantName) +
          " &times; " +
          item.quantity +
          "</span>" +
          "<span>" +
          formatMoney(item.price) +
          "</span>" +
          "</div>";
      });
      html +=
        '<div class="ai-shop-order-summary-total">' +
        "<span>Total</span>" +
        "<span>" +
        formatMoney(total) +
        "</span>" +
        "</div>";
      html += "</div>";

      // Address section (if needed)
      if (needsAddress) {
        html += '<div class="ai-shop-checkout-section">';
        html +=
          '<h3 class="ai-shop-checkout-section-title">Delivery Address</h3>';

        if (s.addresses.length > 0 && !s.showAddressForm) {
          html += '<div class="ai-shop-address-list">';
          s.addresses.forEach(function (addr) {
            var selected = s.selectedAddressId === addr.id;
            html +=
              '<div class="ai-shop-address-option' +
              (selected ? " ai-shop-address-option--selected" : "") +
              '" data-action="SELECT_ADDRESS" data-payload=\'' +
              escapeHtml(JSON.stringify({ addressId: addr.id })) +
              "'>" +
              '<input type="radio" class="ai-shop-address-radio" ' +
              (selected ? "checked" : "") +
              ">" +
              '<div class="ai-shop-address-detail">' +
              '<div class="ai-shop-address-name">' +
              escapeHtml(addr.name || "") +
              "</div>" +
              "<div>" +
              escapeHtml(
                [addr.street, addr.houseNumber, addr.city, addr.country]
                  .filter(Boolean)
                  .join(", ")
              ) +
              "</div>" +
              (addr.postcode
                ? "<div>" + escapeHtml(addr.postcode) + "</div>"
                : "") +
              "</div>" +
              "</div>";
          });
          html += "</div>";
          html +=
            '<button class="ai-shop-link" data-action="SHOW_ADDRESS_FORM" style="margin-top:8px;">' +
            "+ Add new address" +
            "</button>";
        }

        if (s.showAddressForm || s.addresses.length === 0) {
          html += renderAddressForm(s);
        }

        html += "</div>"; // section
      }

      // Place Order button
      var canPlace = !needsAddress || s.selectedAddressId;
      html +=
        '<button class="ai-shop-btn ai-shop-btn--success ai-shop-btn--block" data-action="PLACE_ORDER"' +
        (canPlace ? "" : " disabled") +
        ">" +
        "Place Order" +
        "</button>";

      html += "</div>"; // checkout
      return html;
    }

    // renderPaymentSummary lists total, paid, balance and the balance deadline.
    function renderPaymentSummary(order, ps) {
      function row(label, minor, cls) {
        return (
          '<div class="ai-shop-order-summary-item' + (cls ? " " + cls : "") + '">' +
          "<span>" + label + "</span>" +
          "<span>" + escapeHtml(formatMinor(minor, ps.currency, ps.digits)) + "</span>" +
          "</div>"
        );
      }
      var html = row("Order total", ps.totalMinor);
      html += row("Paid", ps.paidMinor);
      html +=
        '<div class="ai-shop-order-summary-total">' +
        "<span>Balance</span>" +
        "<span>" + escapeHtml(formatMinor(ps.balanceMinor, ps.currency, ps.digits)) + "</span>" +
        "</div>";
      var due = formatDate(ps.balanceDueAt);
      if (due && ps.balanceMinor > 0) {
        html += '<div class="ai-shop-pay-due">Balance due by ' + escapeHtml(due) + "</div>";
      }
      return html;
    }

    function renderPay(s) {
      var order = s.order;
      if (!order) return renderError({ error: "Order not found" });
      var ps = orderPaymentState(order);
      var part = s.payMode === "part";

      var html = '<div class="ai-shop-checkout">';
      html +=
        '<div class="ai-shop-checkout-header">' +
        '<h2 class="ai-shop-checkout-title">Pay for order ' + escapeHtml(order.orderNumber || "") + "</h2>" +
        "</div>";

      html += '<div class="ai-shop-checkout-section">' + renderPaymentSummary(order, ps) + "</div>";

      html += '<div class="ai-shop-checkout-section">';
      html += '<h3 class="ai-shop-checkout-section-title">How much would you like to pay now?</h3>';
      html += '<div class="ai-shop-address-list">';
      html +=
        '<div class="ai-shop-address-option' + (part ? "" : " ai-shop-address-option--selected") +
        '" data-action="SET_PAY_MODE" data-payload=\'{"mode":"full"}\'>' +
        '<input type="radio" class="ai-shop-address-radio" name="ai-shop-pay-mode"' + (part ? "" : " checked") + ">" +
        '<div class="ai-shop-address-detail">' +
        '<div class="ai-shop-address-name">Pay in full</div>' +
        "<div>" + escapeHtml(formatMinor(ps.balanceMinor, ps.currency, ps.digits)) + "</div>" +
        "</div></div>";
      html +=
        '<div class="ai-shop-address-option' + (part ? " ai-shop-address-option--selected" : "") +
        '" data-action="SET_PAY_MODE" data-payload=\'{"mode":"part"}\'>' +
        '<input type="radio" class="ai-shop-address-radio" name="ai-shop-pay-mode"' + (part ? " checked" : "") + ">" +
        '<div class="ai-shop-address-detail">' +
        '<div class="ai-shop-address-name">' + (ps.isDeposit ? "Pay a deposit" : "Pay an instalment") + "</div>" +
        "<div>From " + escapeHtml(formatMinor(ps.minMinor, ps.currency, ps.digits)) +
        (ps.minPercent > 0 ? " (" + ps.minPercent + "% of the total)" : "") +
        "</div>" +
        "</div></div>";
      html += "</div>"; // list

      if (part) {
        html +=
          '<div class="ai-shop-form-group ai-shop-pay-amount">' +
          '<label class="ai-shop-form-label" for="ai-shop-pay-amount-input">Amount (' + escapeHtml(ps.currency) + ")</label>" +
          '<input class="ai-shop-form-input' + (s.payError ? " ai-shop-form-input--error" : "") +
          '" id="ai-shop-pay-amount-input" type="text" inputmode="decimal" autocomplete="off" data-field="payAmount" value="' +
          escapeHtml(s.payAmountInput) + '">' +
          '<span class="ai-shop-pay-hint">Between ' +
          escapeHtml(formatMinor(ps.minMinor, ps.currency, ps.digits)) + " and " +
          escapeHtml(formatMinor(ps.balanceMinor, ps.currency, ps.digits)) + "</span>" +
          (s.payError ? '<span class="ai-shop-form-error">' + escapeHtml(s.payError) + "</span>" : "") +
          "</div>";
      }
      html += "</div>"; // section

      html +=
        '<button class="ai-shop-btn ai-shop-btn--success ai-shop-btn--block" data-action="SUBMIT_PAYMENT">' +
        "Continue to payment" +
        "</button>";
      html += "</div>";
      return html;
    }

    var PAYMENT_STATUS_LABELS = {
      PAYMENT_STATUS_PENDING: "Awaiting payment",
      PAYMENT_STATUS_PAID: "Paid",
      PAYMENT_STATUS_PARTIALLY_PAID: "Partially paid",
      PAYMENT_STATUS_FAILED: "Payment failed",
      PAYMENT_STATUS_REFUNDED: "Refunded",
      PAYMENT_STATUS_EXPIRED: "Expired",
    };

    function renderOrderStatus(s) {
      var order = s.order;
      if (!order) return renderError({ error: "Order not found" });
      var ps = orderPaymentState(order);
      var status = paymentStatusOf(order);
      var label = PAYMENT_STATUS_LABELS[status] || "Pending";
      var cancelled = order.status === "ORDER_STATUS_CANCELLED" || order.status === 2;

      var html = '<div class="ai-shop-checkout">';
      html +=
        '<div class="ai-shop-checkout-header">' +
        '<h2 class="ai-shop-checkout-title">Order ' + escapeHtml(order.orderNumber || "") + "</h2>" +
        '<span class="ai-shop-pay-status ai-shop-pay-status--' +
        escapeHtml(status.replace("PAYMENT_STATUS_", "").toLowerCase()) + '">' +
        escapeHtml(cancelled ? "Cancelled" : label) + "</span>" +
        "</div>";

      html += '<div class="ai-shop-checkout-section">' + renderPaymentSummary(order, ps) + "</div>";

      if (!cancelled && ps.balanceMinor > 0 &&
          (status === "PAYMENT_STATUS_PARTIALLY_PAID" || status === "PAYMENT_STATUS_PENDING" ||
           status === "PAYMENT_STATUS_FAILED")) {
        html +=
          '<button class="ai-shop-btn ai-shop-btn--success ai-shop-btn--block" data-action="PAY_ORDER">' +
          (status === "PAYMENT_STATUS_PARTIALLY_PAID" ? "Pay next instalment" : "Complete payment") +
          "</button>";
      }

      html +=
        '<div class="ai-shop-form-actions ai-shop-pay-actions">' +
        '<button class="ai-shop-btn ai-shop-btn--outline ai-shop-btn--sm" data-action="REFRESH_ORDER">Refresh</button>' +
        '<button class="ai-shop-btn ai-shop-btn--outline ai-shop-btn--sm" data-action="CONTINUE_SHOPPING">Continue shopping</button>' +
        "</div>";
      html += "</div>";
      return html;
    }

    function renderAddressForm(s) {
      var errs = s.addressErrors || {};
      var fields = [
        { key: "name", label: "Full Name", full: true },
        { key: "country", label: "Country" },
        { key: "city", label: "City" },
        { key: "area", label: "Area / Region" },
        { key: "street", label: "Street" },
        { key: "houseNumber", label: "House Number" },
        { key: "postcode", label: "Postcode" },
        { key: "extra", label: "Additional Info", full: true },
      ];

      var html = '<div class="ai-shop-form" id="ai-shop-address-form">';
      fields.forEach(function (f) {
        html +=
          '<div class="ai-shop-form-group' +
          (f.full ? " ai-shop-form-group--full" : "") +
          '">' +
          '<label class="ai-shop-form-label">' +
          escapeHtml(f.label) +
          "</label>" +
          '<input class="ai-shop-form-input' +
          (errs[f.key] ? " ai-shop-form-input--error" : "") +
          '" type="text" name="' +
          f.key +
          '" placeholder="' +
          escapeHtml(f.label) +
          '">' +
          (errs[f.key]
            ? '<span class="ai-shop-form-error">' +
              escapeHtml(errs[f.key]) +
              "</span>"
            : "") +
          "</div>";
      });

      html +=
        '<div class="ai-shop-form-actions">' +
        (s.addresses.length > 0
          ? '<button class="ai-shop-btn ai-shop-btn--outline ai-shop-btn--sm" data-action="SELECT_ADDRESS" data-payload=\'' +
            JSON.stringify({ addressId: s.addresses[0].id }) +
            "'>Cancel</button>"
          : "") +
        '<button class="ai-shop-btn ai-shop-btn--primary ai-shop-btn--sm" data-action="SUBMIT_ADDRESS">' +
        "Save Address" +
        "</button>" +
        "</div>";

      html += "</div>"; // form
      return html;
    }

    function renderToast(s) {
      if (!s.toastMessage) return "";
      return (
        '<div class="ai-shop-toast ai-shop-toast--visible ai-shop-toast--' +
        (s.toastType || "error") +
        '">' +
        escapeHtml(s.toastMessage) +
        "</div>"
      );
    }

    // --- Event delegation ---
    rootEl.addEventListener("click", function (e) {
      var target = e.target.closest("[data-action]");
      if (!target) return;

      var action = target.getAttribute("data-action");
      var payloadStr = target.getAttribute("data-payload");
      var payload = {};
      if (payloadStr) {
        try {
          payload = JSON.parse(payloadStr);
        } catch (err) {
          /* ignore */
        }
      }

      // Special handling for variant selection (need full variant object)
      if (action === "SELECT_VARIANT" && payload.variantId) {
        var s = store.get();
        var product = s.selectedProduct;
        if (product) {
          var variantsList = s.variants[product.id] || [];
          for (var i = 0; i < variantsList.length; i++) {
            if (variantsList[i].id === payload.variantId) {
              payload = { variant: variantsList[i] };
              break;
            }
          }
        }
      }

      // Special handling for address form submission
      if (action === "SUBMIT_ADDRESS") {
        var form = rootEl.querySelector("#ai-shop-address-form");
        if (form) {
          var address = {};
          var inputs = form.querySelectorAll("input[name]");
          for (var i = 0; i < inputs.length; i++) {
            address[inputs[i].name] = inputs[i].value.trim();
          }
          dispatch("ADD_ADDRESS", { address: address });
          return;
        }
      }

      dispatch(action, payload);
    });

    // Keep the typed instalment amount in state without re-rendering, so a
    // later render (toast, mode switch) shows what the buyer typed.
    rootEl.addEventListener("input", function (e) {
      if (e.target && e.target.getAttribute("data-field") === "payAmount") {
        store.patch({ payAmountInput: e.target.value, payError: null });
      }
    });

    // Subscribe to state changes
    store.subscribe(render);

    return { render: render };
  }

  // ============================================================
  // 6. Bootstrap — find widget roots and initialize
  // ============================================================

  function initWidget(rootEl) {
    var configAttr = rootEl.getAttribute("data-config");
    if (!configAttr) return;

    var config;
    try {
      config = JSON.parse(configAttr);
    } catch (e) {
      rootEl.innerHTML =
        '<div class="ai-shop-error"><div class="ai-shop-error-message">Invalid widget configuration</div></div>';
      return;
    }

    var api = createApiClient(config.apiUrl, config.token);
    var profileApi = config.profileApiUrl
      ? createProfileClient(config.profileApiUrl, config.token)
      : null;

    var store = createStore();
    var dispatch = createDispatcher(store, api, profileApi, config);
    var renderer = createRenderer(rootEl, store, dispatch, config);

    renderer.render();
    dispatch("INIT");
  }

  // Auto-initialize all widgets on the page
  function boot() {
    var widgets = document.querySelectorAll(".ai-shop-widget[data-config]");
    for (var i = 0; i < widgets.length; i++) {
      initWidget(widgets[i]);
    }
  }

  // Pure helpers are exported under CommonJS so they can be exercised
  // without a browser; in a page this branch is skipped.
  if (typeof module === "object" && module.exports) {
    module.exports = {
      currencyDigits: currencyDigits,
      moneyToMinor: moneyToMinor,
      minorToMoney: minorToMoney,
      minorToDecimal: minorToDecimal,
      parseDecimalToMinor: parseDecimalToMinor,
      formatMoney: formatMoney,
      ceilPercent: ceilPercent,
      orderPaymentState: orderPaymentState,
      validateInstalment: validateInstalment,
      paymentStatusOf: paymentStatusOf,
    };
  }

  if (typeof document === "undefined") return;
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
