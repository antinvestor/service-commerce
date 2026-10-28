import 'package:antinvestor_api_procurement/antinvestor_api_procurement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'procurement_api.dart';

/// A list loaded page by page with the server's keyset cursor.
class PagedList<T> {
  const PagedList({
    required this.items,
    this.nextPage = '',
    this.loadingMore = false,
    this.loadMoreError,
  });

  final List<T> items;

  /// The server's `next_page`; empty on the last page.
  final String nextPage;
  final bool loadingMore;

  /// Why the last [PagedController.loadMore] failed; the loaded items stay.
  final Object? loadMoreError;

  bool get hasMore => nextPage.isNotEmpty;
}

/// Rows asked for per page by the list screens.
const int listPageSize = 50;

/// A search request for [page] (empty for the first page).
SearchRequest pageSearch(String page, {int limit = listPageSize}) {
  final cursor = PageCursor(limit: limit);
  if (page.isNotEmpty) cursor.page = page;
  return SearchRequest(cursor: cursor);
}

/// Loads the first page on build and appends later pages on [loadMore].
abstract class PagedController<T> extends AsyncNotifier<PagedList<T>> {
  /// Fetches [page] (empty for the first) and returns its rows and the
  /// cursor of the page after it.
  Future<(List<T>, String)> fetchPage(ProcurementApi api, String page);

  @override
  Future<PagedList<T>> build() async {
    final (items, next) = await fetchPage(
      ref.watch(procurementApiProvider),
      '',
    );
    return PagedList(items: items, nextPage: next);
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.loadingMore) return;
    state = AsyncData(
      PagedList(
        items: current.items,
        nextPage: current.nextPage,
        loadingMore: true,
      ),
    );
    try {
      final (items, next) = await fetchPage(
        ref.read(procurementApiProvider),
        current.nextPage,
      );
      state = AsyncData(
        PagedList(items: [...current.items, ...items], nextPage: next),
      );
    } catch (e) {
      state = AsyncData(
        PagedList(
          items: current.items,
          nextPage: current.nextPage,
          loadMoreError: e,
        ),
      );
    }
  }
}

/// Pages fetched at most by [collectPages], so a picker or a count never
/// walks an unbounded table.
const int collectMaxPages = 5;

/// Rows per page when collecting every page.
const int collectPageSize = 200;

/// Every row [fetch] returns across at most [collectMaxPages] pages.
Future<List<T>> collectPages<T>(
  Future<(List<T>, String)> Function(SearchRequest search) fetch,
) async {
  final all = <T>[];
  var page = '';
  for (var i = 0; i < collectMaxPages; i++) {
    final (items, next) = await fetch(pageSearch(page, limit: collectPageSize));
    all.addAll(items);
    if (next.isEmpty) break;
    page = next;
  }
  return all;
}
