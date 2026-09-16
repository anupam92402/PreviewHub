import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/asset_metrics.dart';
import '../models/measurable_asset.dart';
import '../models/preview_asset.dart';
import '../models/validation_issue.dart';

/// Measures an asset's size and dimensions on demand, and remembers the answer.
///
/// Nothing is measured until something watches it: measuring a bundled asset
/// means loading its whole body, and measuring a remote one means a request.
/// Results are cached for the life of the service, so scrolling a grid back and
/// forth costs nothing after the first pass.
class AssetMetricsService {
  /// Measures bundled assets against [bundle] and remote ones with [client].
  AssetMetricsService({
    AssetBundle? bundle,
    http.Client? client,
    this.contentTypePrefixes = const <String>{'image/'},
  }) : _bundle = bundle ?? rootBundle,
       _client = client ?? http.Client();

  /// Content types a served body may claim to be.
  ///
  /// Each collection expects something different — an image gallery wants
  /// `image/`, a Lottie gallery wants JSON — so the check is set by whoever
  /// creates the service rather than hard-coded to one kind of asset.
  final Set<String> contentTypePrefixes;

  final AssetBundle _bundle;
  final http.Client _client;
  final Map<String, ValueNotifier<AssetMetricsState>> _states =
      <String, ValueNotifier<AssetMetricsState>>{};
  final Map<String, Future<void>> _inFlight = <String, Future<void>>{};
  final ValueNotifier<List<ValidationIssue>> _issues =
      ValueNotifier<List<ValidationIssue>>(const <ValidationIssue>[]);

  /// Problems found while fetching, such as a URL that serves a web page.
  ///
  /// This grows as assets resolve, so the report keeps filling in while the
  /// user scrolls rather than being complete only at startup.
  ValueListenable<List<ValidationIssue>> get issues => _issues;

  /// Metrics for [asset], starting the measurement the first time it is watched.
  ValueListenable<AssetMetricsState> watch(MeasurableAsset asset) {
    unawaited(ensureMeasured(asset));
    return _stateFor(asset);
  }

  /// Measures [asset] if it has not been measured, and completes when it has.
  ///
  /// Repeat calls share the first call's work, so watching an asset in the grid
  /// and awaiting it for the validation report costs one request between them.
  Future<void> ensureMeasured(MeasurableAsset asset) =>
      _inFlight[asset.locator] ??= _resolve(asset, _stateFor(asset));

  /// The problem recorded against [asset], or null when there is none.
  ///
  /// Lets a screen name the failure rather than only reporting that there was
  /// one; the grid stays generic, the detail screen says what went wrong.
  ValidationIssue? issueFor(MeasurableAsset asset) => _issues.value
      .where((ValidationIssue issue) => issue.entry == asset.locator)
      .firstOrNull;

  /// Size already measured for [asset], or null while it is still unknown.
  ///
  /// Reads the cache without starting any work, so sorting can consult it
  /// without pulling in assets that were never asked for.
  int? sizeOf(MeasurableAsset asset) =>
      _states[asset.locator]?.value.metrics.sizeInBytes;

  /// Records the pixel size the decoder reported for [asset].
  ///
  /// Dimensions come from the image the UI is already showing, so learning how
  /// big a remote image is costs no extra download.
  void recordDimensions(MeasurableAsset asset, int width, int height) {
    final ValueNotifier<AssetMetricsState> state = _stateFor(asset);
    final AssetMetricsState current = state.value;
    if (current.metrics.width == width && current.metrics.height == height) {
      return;
    }
    state.value = AssetMetricsState(
      status: current.status,
      metrics: current.metrics.withDimensions(width, height),
      error: current.error,
    );
  }

  ValueNotifier<AssetMetricsState> _stateFor(MeasurableAsset asset) =>
      _states[asset.locator] ??= ValueNotifier<AssetMetricsState>(
        AssetMetricsState.loading,
      );

  Future<void> _resolve(
    MeasurableAsset asset,
    ValueNotifier<AssetMetricsState> state,
  ) async {
    try {
      final int? bytes = asset.source == AssetSource.bundled
          ? (await _bundle.load(asset.locator)).lengthInBytes
          : await _networkSize(asset);
      state.value = state.value.ready(state.value.metrics.withSize(bytes));
    } on Object catch (error) {
      _report(
        ValidationIssue(
          entry: asset.locator,
          failure: ValidationFailure.unreachable,
          detail: '$error',
        ),
      );
      state.value = AssetMetricsState(
        status: MetricsStatus.failed,
        metrics: state.value.metrics,
        error: '$error',
      );
    }
  }

  /// Asks for the size with a HEAD, falling back to a GET when the server
  /// refuses HEAD or omits `content-length`. Both happen in practice.
  Future<int?> _networkSize(MeasurableAsset asset) async {
    final Uri uri = Uri.parse(asset.locator);
    try {
      final http.Response head = await _client.head(uri);
      if (head.statusCode < 400) {
        _checkContentType(asset, head.headers['content-type']);
        final int? length = int.tryParse(head.headers['content-length'] ?? '');
        if (length != null) {
          return length;
        }
      }
    } on Object {
      // HEAD is optional for a server; fall through and try a GET.
    }

    final http.Response body = await _client.get(uri);
    if (body.statusCode >= 400) {
      throw http.ClientException('HTTP ${body.statusCode}', uri);
    }
    _checkContentType(asset, body.headers['content-type']);
    return body.bodyBytes.length;
  }

  /// Flags a URL whose body the server does not describe as an image.
  ///
  /// This rides along on the request already being made for the size, so it
  /// costs nothing extra.
  void _checkContentType(MeasurableAsset asset, String? contentType) {
    if (contentType == null ||
        contentTypePrefixes.any(contentType.startsWith)) {
      return;
    }
    _report(
      ValidationIssue(
        entry: asset.locator,
        failure: ValidationFailure.unexpectedContentType,
        detail: contentType.split(';').first.trim(),
      ),
    );
  }

  void _report(ValidationIssue issue) {
    if (_issues.value.contains(issue)) {
      return;
    }
    _issues.value = <ValidationIssue>[..._issues.value, issue];
  }

  /// Releases every cached notifier and the HTTP client.
  void dispose() {
    for (final ValueNotifier<AssetMetricsState> state in _states.values) {
      state.dispose();
    }
    _states.clear();
    _inFlight.clear();
    _issues.dispose();
    _client.close();
  }
}
