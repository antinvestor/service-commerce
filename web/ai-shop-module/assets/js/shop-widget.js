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
      },
      initial || {}
    );

    var listeners = [];

    return {
      get: function () {
        return state;
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

  function formatMoney(moneyObj) {
    if (!moneyObj) return "";
    var units = parseInt(moneyObj.units || "0", 10);
    var nanos = parseInt(moneyObj.nanos || "0", 10);
    var amount = units + nanos / 1e9;
    var currency = moneyObj.currencyCode || "";
    try {
      return new Intl.NumberFormat(undefined, {
        style: "currency",
        currency: currency,
      }).format(amount);
    } catch (e) {
      return currency + " " + amount.toFixed(2);
    }
  }

  function moneyToDecimal(moneyObj) {
    if (!moneyObj) return "0.00";
    var units = parseInt(moneyObj.units || "0", 10);
    var nanos = parseInt(moneyObj.nanos || "0", 10);
    return (units + nanos / 1e9).toFixed(2);
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
      var totalUnits = 0;
      var totalNanos = 0;
      var currency = "";
      items.forEach(function (item) {
        if (item.price) {
          currency = item.price.currencyCode || currency;
          totalUnits += (parseInt(item.price.units || "0", 10)) * item.quantity;
          totalNanos += (parseInt(item.price.nanos || "0", 10)) * item.quantity;
        }
      });
      totalUnits += Math.floor(totalNanos / 1e9);
      totalNanos = totalNanos % 1e9;
      return { currencyCode: currency, units: String(totalUnits), nanos: String(totalNanos) };
    }

    var dispatch = function (action, payload) {
      var s = store.get();

      switch (action) {
        case "INIT":
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
              if (paymentUrl && order) {
                var sep = paymentUrl.indexOf("?") >= 0 ? "&" : "?";
                var redirect =
                  paymentUrl +
                  sep +
                  "orderId=" + encodeURIComponent(order.id) +
                  "&orderNumber=" + encodeURIComponent(order.orderNumber || "") +
                  "&total=" + encodeURIComponent(moneyToDecimal(order.total)) +
                  "&currency=" + encodeURIComponent((order.total && order.total.currencyCode) || "");
                window.location.href = redirect;
              } else {
                showToast("Order placed successfully!", "success");
                dispatch("INIT");
              }
            })
            .catch(function (err) {
              store.setState({ screen: "checkout" });
              showToast(err.message || "Failed to place order");
            });
          break;

        case "IMMEDIATE_ORDER":
          if (!s.selectedVariant || !s.selectedProduct) return;
          store.setState({ screen: "loading" });
          api
            .createOrder(shopId, profileId, [
              {
                variantId: s.selectedVariant.id,
                quantity: s.quantity,
              },
            ])
            .then(function (r) {
              var order = r.order;
              if (paymentUrl && order) {
                var sep = paymentUrl.indexOf("?") >= 0 ? "&" : "?";
                var redirect =
                  paymentUrl +
                  sep +
                  "orderId=" + encodeURIComponent(order.id) +
                  "&orderNumber=" + encodeURIComponent(order.orderNumber || "") +
                  "&total=" + encodeURIComponent(moneyToDecimal(order.total)) +
                  "&currency=" + encodeURIComponent((order.total && order.total.currencyCode) || "");
                window.location.href = redirect;
              } else {
                showToast("Order placed successfully!", "success");
                dispatch("INIT");
              }
            })
            .catch(function (err) {
              store.setState({ screen: "detail" });
              showToast(err.message || "Failed to place order");
            });
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

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
