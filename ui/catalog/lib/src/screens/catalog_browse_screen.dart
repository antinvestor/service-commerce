import 'package:antinvestor_api_commerce/antinvestor_api_commerce.dart';
import 'package:antinvestor_ui_core/widgets/error_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/catalog_providers.dart';
import '../widgets/fulfilment_type_badge.dart';
import '../widgets/product_status_badge.dart';

/// Admin-grade catalog browse screen with DataTable, search, status filter
/// chips, and FAB for new product creation.
class CatalogBrowseScreen extends ConsumerStatefulWidget {
  const CatalogBrowseScreen({
    super.key,
    required this.shopId,
  });

  final String shopId;

  @override
  ConsumerState<CatalogBrowseScreen> createState() =>
      _CatalogBrowseScreenState();
}

class _CatalogBrowseScreenState extends ConsumerState<CatalogBrowseScreen> {
  String _query = '';
  ProductStatus? _selectedStatus;
  int? _selectedIndex;
  int _currentPage = 0;
  int _pageSize = 25;
  final _searchController = TextEditingController();

  static const _pageSizeOptions = [10, 25, 50, 100];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final asyncProducts = _query.length >= 2
        ? ref.watch(productSearchProvider(
            (shopId: widget.shopId, query: _query)))
        : ref.watch(productListProvider(widget.shopId));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/catalog/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
      body: asyncProducts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load products',
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(friendlyError(error),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    ref.invalidate(productListProvider(widget.shopId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (products) {
          final filtered = _selectedStatus != null
              ? products
                  .where((p) => p.status == _selectedStatus)
                  .toList()
              : products;
          return _buildContent(context, theme, filtered);
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ThemeData theme, List<Product> products) {
    if (_selectedIndex != null && _selectedIndex! >= products.length) {
      _selectedIndex = null;
    }

    final showDetail = _selectedIndex != null;
    final totalPages = (products.length / _pageSize).ceil();
    final pageStart = _currentPage * _pageSize;
    final pageEnd = (pageStart + _pageSize).clamp(0, products.length);
    final pageItems =
        products.isNotEmpty ? products.sublist(pageStart, pageEnd) : <Product>[];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: showDetail ? 3 : 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.storefront_outlined,
                        size: 28, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Product Catalog',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600)),
                          if (products.isNotEmpty)
                            Text('${products.length} products',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => context.go('/catalog/new'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Product'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search + status filter
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _query = value.trim();
                            _currentPage = 0;
                            _selectedIndex = null;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search products by name...',
                          prefixIcon: Icon(Icons.search, size: 20),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildStatusFilter(theme),
                  ],
                ),
                const SizedBox(height: 12),

                // Status filter chips
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedStatus == null,
                      onSelected: (_) => setState(() {
                        _selectedStatus = null;
                        _currentPage = 0;
                      }),
                    ),
                    FilterChip(
                      label: const Text('Active'),
                      selected: _selectedStatus ==
                          ProductStatus.PRODUCT_STATUS_ACTIVE,
                      onSelected: (_) => setState(() {
                        _selectedStatus =
                            ProductStatus.PRODUCT_STATUS_ACTIVE;
                        _currentPage = 0;
                      }),
                    ),
                    FilterChip(
                      label: const Text('Inactive'),
                      selected: _selectedStatus ==
                          ProductStatus.PRODUCT_STATUS_INACTIVE,
                      onSelected: (_) => setState(() {
                        _selectedStatus =
                            ProductStatus.PRODUCT_STATUS_INACTIVE;
                        _currentPage = 0;
                      }),
                    ),
                    FilterChip(
                      label: const Text('Archived'),
                      selected: _selectedStatus ==
                          ProductStatus.PRODUCT_STATUS_ARCHIVED,
                      onSelected: (_) => setState(() {
                        _selectedStatus =
                            ProductStatus.PRODUCT_STATUS_ARCHIVED;
                        _currentPage = 0;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Data table
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        showCheckboxColumn: false,
                        columns: const [
                          DataColumn(label: Text('NAME')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('FULFILMENT')),
                        ],
                        rows: List.generate(pageItems.length, (i) {
                          final product = pageItems[i];
                          final globalIndex = pageStart + i;
                          return DataRow(
                            selected: _selectedIndex == globalIndex,
                            onSelectChanged: (_) {
                              setState(
                                  () => _selectedIndex = globalIndex);
                            },
                            color: WidgetStateProperty.resolveWith(
                                (states) {
                              if (states
                                  .contains(WidgetState.selected)) {
                                return theme
                                    .colorScheme.primaryContainer
                                    .withAlpha(40);
                              }
                              return null;
                            }),
                            cells: [
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2_outlined,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(product.name.isNotEmpty
                                        ? product.name
                                        : product.id),
                                  ],
                                ),
                                onTap: () => context
                                    .go('/catalog/${product.id}'),
                              ),
                              DataCell(ProductStatusBadge(
                                  status: product.status)),
                              DataCell(FulfilmentTypeBadge(
                                  type: product.fulfilmentType)),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                ),

                // Pagination footer
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text('Rows per page:',
                            style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        DropdownButton<int>(
                          value: _pageSize,
                          underline: const SizedBox(),
                          items: _pageSizeOptions
                              .map((s) => DropdownMenuItem(
                                  value: s, child: Text('$s')))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() {
                                _pageSize = v;
                                _currentPage = 0;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          products.isEmpty
                              ? '0 of 0'
                              : '${pageStart + 1}-$pageEnd of ${products.length}',
                          style: theme.textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          onPressed: _currentPage > 0
                              ? () =>
                                  setState(() => _currentPage--)
                              : null,
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.chevron_right, size: 20),
                          onPressed:
                              _currentPage < totalPages - 1
                                  ? () => setState(
                                      () => _currentPage++)
                                  : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Detail panel
        if (showDetail && _selectedIndex! < products.length)
          SizedBox(
            width: 380,
            child: Container(
              margin:
                  const EdgeInsets.only(top: 24, right: 24, bottom: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.open_in_new, size: 20),
                          tooltip: 'Open detail page',
                          onPressed: () => context.go(
                              '/catalog/${products[_selectedIndex!].id}'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () =>
                              setState(() => _selectedIndex = null),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _ProductDetailPanel(
                          product: products[_selectedIndex!]),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusFilter(ThemeData theme) {
    return PopupMenuButton<ProductStatus?>(
      icon: Icon(
        _selectedStatus != null
            ? Icons.filter_alt
            : Icons.filter_alt_outlined,
        size: 20,
      ),
      tooltip: 'Filter by status',
      onSelected: (status) => setState(() {
        _selectedStatus = status;
        _currentPage = 0;
      }),
      itemBuilder: (context) => [
        const PopupMenuItem(value: null, child: Text('All Statuses')),
        const PopupMenuDivider(),
        const PopupMenuItem(
            value: ProductStatus.PRODUCT_STATUS_ACTIVE,
            child: Text('Active')),
        const PopupMenuItem(
            value: ProductStatus.PRODUCT_STATUS_INACTIVE,
            child: Text('Inactive')),
        const PopupMenuItem(
            value: ProductStatus.PRODUCT_STATUS_ARCHIVED,
            child: Text('Archived')),
      ],
    );
  }
}

class _ProductDetailPanel extends StatelessWidget {
  const _ProductDetailPanel({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.isNotEmpty ? product.name : 'Unnamed',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(product.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _DetailRow(label: 'Status', child: ProductStatusBadge(status: product.status)),
        _DetailRow(
            label: 'Fulfilment',
            child: FulfilmentTypeBadge(type: product.fulfilmentType)),
        if (product.description.isNotEmpty)
          _DetailRow(label: 'Description', value: product.description),
        if (product.shopId.isNotEmpty)
          _DetailRow(label: 'Shop ID', value: product.shopId),
        if (product.attributes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Attributes',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          for (final entry in product.attributes.entries)
            _DetailRow(label: entry.key, value: entry.value),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: child ??
                Text(value ?? '',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
