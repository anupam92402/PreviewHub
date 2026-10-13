import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/other_asset.dart';
import '../models/preview_asset.dart';
import 'lottie_document.dart';

/// Finds the bundled files no other collection shows: audio, video, data,
/// documents and anything else in the asset manifest that is not an image,
/// icon, font, Lottie or Rive file. [load] reads each file once to measure it;
/// nothing is decoded or played, so listing a video costs a read, not a media
/// dependency. [locate] skips the measuring and reads only JSON, which is
/// needed to leave Lottie files out.
class OtherAssetCatalogService {
  /// Reads files from [bundle], defaulting to the app's own bundle.
  OtherAssetCatalogService({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Font file extensions, for fonts bundled as plain assets.
  static const Set<String> _fontExtensions = <String>{'ttf', 'otf', 'ttc'};

  /// Every bundled file outside the other collections, measured, sorted by
  /// key.
  Future<List<OtherAsset>> load() async {
    final List<OtherAsset> found = <OtherAsset>[];
    for (final (OtherAssetLocation location, ByteData? read)
        in await _candidates()) {
      final ByteData data;
      try {
        data = read ?? await _bundle.load(location.locator);
      } on Object catch (_) {
        continue;
      }
      found.add(
        OtherAsset(
          locator: location.locator,
          kind: location.kind,
          sizeInBytes: data.lengthInBytes,
        ),
      );
    }
    return found;
  }

  /// Every bundled file outside the other collections, unmeasured, sorted by
  /// key. Cheap enough to run when a search starts.
  Future<List<OtherAssetLocation>> locate() async => <OtherAssetLocation>[
    for (final (OtherAssetLocation location, ByteData? _)
        in await _candidates())
      location,
  ];

  /// The files that belong here, each with its bytes when they had to be read
  /// to decide: a JSON file is read to tell a Lottie from anything else, and
  /// [load] reuses that read rather than loading the file twice.
  Future<List<(OtherAssetLocation, ByteData?)>> _candidates() async {
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(
      _bundle,
    );
    final Set<String> fontFiles = await _fontFiles();
    final List<(OtherAssetLocation, ByteData?)> found =
        <(OtherAssetLocation, ByteData?)>[];

    final List<String> keys = manifest.listAssets()..sort();
    for (final String key in keys) {
      final String extension = _extensionOf(key);
      if (AssetType.fromLocator(key) != null ||
          extension == 'riv' ||
          fontFiles.contains(key) ||
          _fontExtensions.contains(extension)) {
        continue;
      }
      ByteData? data;
      if (extension == 'json') {
        try {
          data = await _bundle.load(key);
        } on Object catch (_) {
          continue;
        }
        if (_isLottie(data)) {
          continue;
        }
      }
      found.add((
        OtherAssetLocation(
          locator: key,
          kind: OtherAssetKind.fromExtension(extension),
        ),
        data,
      ));
    }
    return found;
  }

  /// Whether the JSON in [data] is a Lottie animation, which the Lottie
  /// collection already lists.
  static bool _isLottie(ByteData data) => LottieDocument.describesAnimation(
    utf8.decode(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      allowMalformed: true,
    ),
  );

  /// Every font file the font manifest names. An app without one has none.
  Future<Set<String>> _fontFiles() async {
    final Set<String> files = <String>{};
    try {
      final List<dynamic> manifest =
          jsonDecode(await _bundle.loadString('FontManifest.json'))
              as List<dynamic>;
      for (final Map<String, dynamic> family
          in manifest.cast<Map<String, dynamic>>()) {
        for (final Map<String, dynamic> font
            in (family['fonts'] as List<dynamic>? ?? <dynamic>[])
                .cast<Map<String, dynamic>>()) {
          final String? asset = font['asset'] as String?;
          if (asset != null) {
            files.add(asset);
          }
        }
      }
    } on Object catch (_) {}
    return files;
  }

  static String _extensionOf(String key) {
    final String path = Uri.tryParse(key)?.path ?? key;
    final int dot = path.lastIndexOf('.');
    final int slash = path.lastIndexOf('/');
    return dot <= slash ? '' : path.substring(dot + 1).toLowerCase();
  }
}
