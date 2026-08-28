import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper widget that handles [AsyncValue<T>] loading/error/data states.
///
/// Reduces boilerplate in screens that repeatedly do:
/// ```dart
/// async.when(
///   loading: () => SkeletonLoader...,
///   error: (e, st) => ErrorRetryView...,
///   data: (data) => ...
/// )
/// ```
///
/// Usage:
/// ```dart
/// AsyncDataWidget(
///   async: myProvider,
///   loading: () => SkeletonLoader.list(count: 3),
///   error: (e, retry) => ErrorRetryView(
///     message: 'Gagal memuat data',
///     onRetry: retry,
///   ),
///   data: (data) => MyListView(items: data),
/// )
/// ```
class AsyncDataWidget<T> extends StatelessWidget {
  /// The async value to handle.
  final AsyncValue<T> async;

  /// Widget to show while loading.
  final Widget Function() loading;

  /// Widget to show on error. Receives the error and a retry callback.
  final Widget Function(Object error, VoidCallback retry) error;

  /// Widget to show when data is available.
  final Widget Function(T data) data;

  const AsyncDataWidget({
    super.key,
    required this.async,
    required this.loading,
    required this.error,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: loading,
      error: (e, st) => error(e, () {}),
      data: data,
    );
  }
}

/// Helper widget that handles [AsyncValue<List<T>>] for list screens.
///
/// Provides built-in empty state handling alongside loading/error/data.
///
/// Usage:
/// ```dart
/// AsyncListWidget(
///   async: reportsProvider,
///   loading: () => SkeletonLoader.list(count: 5),
///   error: (e, retry) => ErrorRetryView(
///     message: 'Gagal memuat laporan',
///     onRetry: retry,
///   ),
///   empty: () => EmptyStateView(
///     icon: Icons.inbox_outlined,
///     title: 'Belum ada laporan',
///     subtitle: 'Laporan yang Anda buat akan muncul di sini',
///   ),
///   itemBuilder: (report, index) => ReportListItem(report: report),
/// )
/// ```
class AsyncListWidget<T> extends StatelessWidget {
  /// The async list value to handle.
  final AsyncValue<List<T>> async;

  /// Widget to show while loading.
  final Widget Function() loading;

  /// Widget to show on error. Receives the error and a retry callback.
  final Widget Function(Object error, VoidCallback retry) error;

  /// Widget to show when the list is empty.
  final Widget Function() empty;

  /// Builder for each list item. Receives the item and its index.
  final Widget Function(T item, int index) itemBuilder;

  const AsyncListWidget({
    super.key,
    required this.async,
    required this.loading,
    required this.error,
    required this.empty,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: loading,
      error: (e, st) => error(e, () {}),
      data: (items) {
        if (items.isEmpty) {
          return empty();
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(items[index], index),
        );
      },
    );
  }
}
