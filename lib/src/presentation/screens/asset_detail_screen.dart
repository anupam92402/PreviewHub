import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/preview_asset.dart';
import '../../domain/models/validation_issue.dart';
import '../../domain/services/asset_metrics_service.dart';
import '../../preview_hub_strings.dart';
import '../theme/asset_type_style.dart';
import '../widgets/asset_preview.dart';
import '../widgets/asset_tile.dart';

/// Everything known about one asset, with the artwork at full size.
///
/// Where the grid only says an asset is broken, this names the failure.
class AssetDetailScreen extends StatefulWidget {
  /// Creates the detail screen for [asset].
  const AssetDetailScreen({
    required this.asset,
    required this.metrics,
    super.key,
  });

  /// Asset being inspected.
  final PreviewAsset asset;

  /// Shared measurement cache.
  final AssetMetricsService metrics;

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  final ValueNotifier<bool> _failed = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _failed.dispose();
    super.dispose();
  }

  /// Names the failure, falling back to a plain sentence when the cause was
  /// never recorded, as with a bundled file that simply will not decode.
  String _describeFailure() {
    final ValidationIssue? issue = widget.metrics.issueFor(widget.asset);
    if (issue == null) {
      return PreviewHubStrings.assetCannotDisplay;
    }
    return issue.detail == null
        ? issue.failure.message
        : '${issue.failure.message} (${issue.detail})';
  }

  @override
  Widget build(BuildContext context) {
    final PreviewAsset asset = widget.asset;
    final AssetMetricsService metrics = widget.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _failed,
            builder: (BuildContext context, bool failed, Widget? child) {
              final Color accent = failed
                  ? Theme.of(context).colorScheme.error
                  : AssetTypeStyle.colorOf(asset.type);

              return Container(
                height: 280,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: failed ? 0.10 : 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: failed
                    ? AssetPreviewFailure(accent: accent, iconSize: 44)
                    : AssetPreview(
                        asset: asset,
                        onDimensions: (int width, int height) =>
                            metrics.recordDimensions(asset, width, height),
                        onFailed: () => _failed.value = true,
                      ),
              );
            },
          ),
          const SizedBox(height: 22),
          ValueListenableBuilder<AssetMetricsState>(
            valueListenable: metrics.watch(asset),
            builder:
                (
                  BuildContext context,
                  AssetMetricsState state,
                  Widget? child,
                ) => Column(
                  children: <Widget>[
                    _Row(
                      label: PreviewHubStrings.detailName,
                      value: asset.name,
                    ),
                    _Row(
                      label: PreviewHubStrings.detailType,
                      value: asset.type.label,
                      valueColor: AssetTypeStyle.colorOf(asset.type),
                    ),
                    _Row(
                      label: PreviewHubStrings.detailSource,
                      value: asset.source.label,
                    ),
                    _Row(
                      label: PreviewHubStrings.detailDimensions,
                      value: state.status == MetricsStatus.failed
                          ? PreviewHubStrings.assetUnavailable
                          : describeDimensions(asset, state.metrics),
                    ),
                    _Row(
                      label: PreviewHubStrings.detailSize,
                      value: switch (state.status) {
                        MetricsStatus.loading => PreviewHubStrings.measuring,
                        MetricsStatus.failed =>
                          PreviewHubStrings.assetUnavailable,
                        MetricsStatus.ready => AssetMetrics.formatBytes(
                          state.metrics.sizeInBytes,
                        ),
                      },
                    ),
                    _Row(
                      label: asset.source == AssetSource.bundled
                          ? PreviewHubStrings.detailPath
                          : PreviewHubStrings.detailUrl,
                      value: asset.locator,
                      onCopy: () => _copy(context, asset.locator),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _failed,
                      builder:
                          (BuildContext context, bool failed, Widget? child) =>
                              failed || state.status == MetricsStatus.failed
                              ? _Row(
                                  label: PreviewHubStrings.detailError,
                                  value: _describeFailure(),
                                  valueColor: Theme.of(
                                    context,
                                  ).colorScheme.error,
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(PreviewHubStrings.copied),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// One label/value line, optionally with a copy button.
class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.valueColor,
    this.onCopy,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.35,
                color: valueColor,
                fontWeight: valueColor == null ? null : FontWeight.w700,
              ),
            ),
          ),
          if (onCopy != null)
            IconButton(
              onPressed: onCopy,
              tooltip: PreviewHubStrings.copy,
              iconSize: 17,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
    );
  }
}
