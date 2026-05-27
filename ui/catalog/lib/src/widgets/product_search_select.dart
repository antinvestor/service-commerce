import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

/// An embeddable search-and-select widget for products within a shop.
///
/// Shows a text field that searches products as the user types, displays
/// results in a dropdown overlay, and calls [onSelected] when a product
/// is picked.
class ProductSearchSelect extends ConsumerStatefulWidget {
  const ProductSearchSelect({
    super.key,
    required this.shopId,
    required this.onSelected,
    this.label = 'Search products',
    this.initialQuery = '',
    this.autofocus = false,
  });

  final String shopId;
  final ValueChanged<Product> onSelected;
  final String label;
  final String initialQuery;
  final bool autofocus;

  @override
  ConsumerState<ProductSearchSelect> createState() =>
      _ProductSearchSelectState();
}

class _ProductSearchSelectState extends ConsumerState<ProductSearchSelect> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value.trim());
    if (_query.length >= 2) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final width = renderBox.size.width;

    _overlay = OverlayEntry(
      builder: (_) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, renderBox.size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: _ResultsList(
              shopId: widget.shopId,
              query: _query,
              onSelected: _onProductSelected,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _onProductSelected(Product product) {
    _removeOverlay();
    _controller.text = product.name.isNotEmpty ? product.name : product.id;
    _query = '';
    widget.onSelected(product);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        onChanged: _onQueryChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: const Icon(Icons.search, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}

class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.shopId,
    required this.query,
    required this.onSelected,
  });

  final String shopId;
  final String query;
  final ValueChanged<Product> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      productSearchProvider((shopId: shopId, query: query)),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: results.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Search failed',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        data: (products) {
          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No products found'),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(product.name.isNotEmpty
                    ? product.name
                    : product.id),
                subtitle: product.description.isNotEmpty
                    ? Text(
                        product.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                onTap: () => onSelected(product),
              );
            },
          );
        },
      ),
    );
  }
}
