import 'package:flutter/material.dart';

import '../../../domain/models/other_asset.dart';
import '../../../domain/services/other_asset_catalog_service.dart';
import '../../../util/preview_hub_strings.dart';
import '../../viewmodels/other_assets_view_model.dart';
import '../../widgets/common/copied_snack_bar.dart';
import '../../widgets/common/info_note.dart';
import '../../widgets/common/loading_message.dart';
import '../../widgets/common/status_message.dart';
import '../../widgets/other_assets/other_asset_group_header.dart';
import '../../widgets/other_assets/other_asset_tile.dart';
import '../../widgets/other_assets/other_assets_summary.dart';

/// Every bundled file no other collection shows, under one heading per kind:
/// audio, video, JSON, PDF and unknown. A kind with no files gets no heading.
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

  void _copy(OtherAsset asset) => CopiedSnackBar.copy(
    context,
    asset.locator,
    message: PreviewHubStrings.copiedPath(asset.locator),
  );

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
          return const LoadingMessage(message: PreviewHubStrings.otherLoading);
        }
        if (_viewModel.failed) {
          return const StatusMessage(
            icon: Icons.error_outline_rounded,
            message: PreviewHubStrings.otherFailed,
          );
        }
        final List<OtherAssetGroup> groups = _viewModel.groups;
        if (groups.isEmpty) {
          return const StatusMessage(
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
            OtherAssetsSummary(
              fileCount: _viewModel.fileCount,
              totalBytes: _viewModel.totalBytes,
            ),
            for (final OtherAssetGroup group in groups) ...<Widget>[
              OtherAssetGroupHeader(group: group),
              for (final OtherAsset asset in group.assets)
                OtherAssetTile(asset: asset, onTap: () => _copy(asset)),
            ],
            const SizedBox(height: 12),
            const InfoNote(text: PreviewHubStrings.otherNote),
          ],
        );
      },
    ),
  );
}
