import 'package:flutter/foundation.dart';

/// What sort of file an [OtherAsset] is, read off its extension. The order
/// here is the order the headings appear in on the screen.
enum OtherAssetKind {
  /// Sound files.
  audio('Audio', <String>{
    'mp3',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'oga',
    'opus',
    'flac',
    'amr',
  }),

  /// Video files.
  video('Video', <String>{'mp4', 'm4v', 'mov', 'webm', 'mkv', 'avi', '3gp'}),

  /// JSON that is not a Lottie animation: config, translations, mock data.
  json('JSON', <String>{'json'}),

  /// PDF documents.
  pdf('PDF', <String>{'pdf'}),

  /// Anything else the app bundles.
  unknown('Unknown', <String>{});

  const OtherAssetKind(this.label, this.extensions);

  /// Heading the files are listed under.
  final String label;

  /// Lower-case extensions that belong to this kind.
  final Set<String> extensions;

  /// The kind [extension] belongs to, or [unknown].
  static OtherAssetKind fromExtension(String extension) => values.firstWhere(
    (OtherAssetKind kind) => kind.extensions.contains(extension),
    orElse: () => unknown,
  );
}

/// A bundled file that is not an image, icon, font, Lottie or Rive file.
/// Listed by name and size only: nothing is played or opened, so the gallery
/// needs no media dependency to show it.
@immutable
class OtherAsset {
  /// Describes the bundled file at [locator].
  const OtherAsset({
    required this.locator,
    required this.kind,
    required this.sizeInBytes,
  });

  /// The manifest key exactly as Flutter exposes it.
  final String locator;

  /// Which heading the file is listed under.
  final OtherAssetKind kind;

  /// Bytes of the file as bundled.
  final int sizeInBytes;

  /// File name, for the list.
  String get name => _lastSegment(locator);

  /// Upper-case extension, such as `MP3`, or empty when there is none.
  String get extension {
    final int dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toUpperCase();
  }
}

/// Where an [OtherAsset] is and what kind it is, without its size. What the
/// landing screen's search matches against: knowing a file exists costs a
/// manifest lookup, measuring it costs a full read.
@immutable
class OtherAssetLocation {
  /// Describes the bundled file at [locator].
  const OtherAssetLocation({required this.locator, required this.kind});

  /// The manifest key exactly as Flutter exposes it.
  final String locator;

  /// Which heading the file is listed under.
  final OtherAssetKind kind;

  /// File name, for a search hit.
  String get name => _lastSegment(locator);
}

/// The last segment of [path], or [path] itself when it has none.
String _lastSegment(String path) =>
    path.split('/').where((String part) => part.isNotEmpty).lastOrNull ?? path;

/// The files of one kind, heaviest first.
@immutable
class OtherAssetGroup {
  /// Creates a group of [kind] holding [assets].
  const OtherAssetGroup({required this.kind, required this.assets});

  /// Kind every file in the group shares.
  final OtherAssetKind kind;

  /// Files in the group, heaviest first.
  final List<OtherAsset> assets;

  /// Bytes of every file in the group.
  int get totalBytes => assets.fold(
    0,
    (int total, OtherAsset asset) => total + asset.sizeInBytes,
  );
}
