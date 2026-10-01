import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/models/asset_metrics.dart';
import '../../domain/models/other_asset.dart';
import '../../domain/services/other_asset_catalog_service.dart';
import '../../preview_hub_strings.dart';
import '../viewmodels/other_assets_view_model.dart';
import '../widgets/other_asset_group_header.dart';
import '../widgets/other_asset_tile.dart';

/// Every bundled file no other collection shows, under one heading per kind:
/// audio, video, JSON, PDF and unknown. A kind with no files gets no heading.
///
/// Files are listed by name and size only. Nothing is played or opened, so the
/// gallery takes on no media dependency; a tap copies the file's path.
class OtherAssetsScreen extends StatefulWidget {
  /// Creates the screen.
  const OtherAssetsScreen({super.key});

  @override
  State<OtherAssetsScreen> createState() => _OtherAssetsScreenState();
}

class _OtherAssetsScreenState extends State<OtherAssetsScreen> {
  final OtherAssetsViewModel _viewModel = OtherAssetsViewModel(
    catalog: OtherAssetCatalogService(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _copy(OtherAsset asset) {
    Clipboard.setData(ClipboardData(text: asset.locator));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(PreviewHubStrings.copiedPath(asset.locator)),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(PreviewHubStrings.sectionOtherTitle),
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    body: ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        if (_viewModel.isLoading) {
          return const _Loading();
        }
        if (_viewModel.failed) {
          return const _Message(
            icon: Icons.error_outline_rounded,
            message: PreviewHubStrings.otherFailed,
          );
        }
        final List<OtherAssetGroup> groups = _viewModel.groups;
        if (groups.isEmpty) {
          return const _Message(
            icon: Icons.folder_open_rounded,
            message: PreviewHubStrings.otherEmpty,
          );
        }

        return ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            4,
            16,
            MediaQuery.paddingOf(context).bottom + 28,
          ),
          children: <Widget>[
            _Summary(
              fileCount: _viewModel.fileCount,
              totalBytes: _viewModel.totalBytes,
            ),
            for (final OtherAssetGroup group in groups) ...<Widget>[
              OtherAssetGroupHeader(group: group),
              for (final OtherAsset asset in group.assets)
                OtherAssetTile(asset: asset, onTap: () => _copy(asset)),
            ],
            const SizedBox(height: 12),
            const _Note(),
          ],
        );
      },
    ),
  );
}

/// How many files there are and what they weigh together.
class _Summary extends StatelessWidget {
  const _Summary({required this.fileCount, required this.totalBytes});

  final int fileCount;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
      child: Text(
        PreviewHubStrings.otherSummary(
          fileCount,
          AssetMetrics.formatBytes(totalBytes),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Why nothing here plays.
class _Note extends StatelessWidget {
  const _Note();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            PreviewHubStrings.otherNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown while the bundle is being read.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const CircularProgressIndicator(),
        const SizedBox(height: 14),
        Text(
          PreviewHubStrings.otherLoading,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

/// A glyph and a sentence, for the empty and failed states.
class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 34, color: scheme.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
