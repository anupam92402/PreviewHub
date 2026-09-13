/// Network endpoints the gallery is exercised against.
///
/// A real consumer supplies their own; these cover every supported format.
library;

/// A network asset with a label to show alongside it.
class NetworkAsset {
  /// Creates a named network asset.
  const NetworkAsset({required this.name, required this.url});

  /// Label shown with the asset.
  final String name;

  /// Absolute http or https URL.
  final String url;
}

/// PNG endpoints.
const List<String> pngs = <String>[
  'https://picsum.photos/400/400.png',
  'https://picsum.photos/500/300.png',
  'https://picsum.photos/600/400.png',
  'https://picsum.photos/800/600.png',
  'https://picsum.photos/300/500.png',
];

/// SVG endpoints.
const List<String> svgs = <String>[
  'https://upload.wikimedia.org/wikipedia/commons/0/02/SVG_logo.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/car.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/cartman.svg',
  'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/helloworld.svg',
];

/// WebP endpoints.
const List<String> webps = <String>[
  'https://www.gstatic.com/webp/gallery/1.webp',
  'https://www.gstatic.com/webp/gallery/2.webp',
  'https://www.gstatic.com/webp/gallery/3.webp',
  'https://www.gstatic.com/webp/gallery/4.webp',
  'https://www.gstatic.com/webp/gallery/5.webp',
];

/// JPEG endpoints.
const List<String> jpegs = <String>[
  'https://picsum.photos/id/10/800/600.jpg',
  'https://picsum.photos/id/20/800/600.jpg',
  'https://picsum.photos/id/30/800/600.jpg',
  'https://picsum.photos/id/40/800/600.jpg',
  'https://picsum.photos/id/50/800/600.jpg',
];

/// GIF endpoints.
const List<NetworkAsset> gifs = <NetworkAsset>[
  NetworkAsset(
    name: 'Loading',
    url: 'https://media.giphy.com/media/3oEjI6SIIHBdRxXI40/giphy.gif',
  ),
  NetworkAsset(
    name: 'Success',
    url: 'https://media.giphy.com/media/ICOgUNjpvO0PC/giphy.gif',
  ),
  NetworkAsset(
    name: 'Rocket',
    url: 'https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif',
  ),
  NetworkAsset(
    name: 'Coding',
    url: 'https://media.giphy.com/media/ZVik7pBtu9dNS/giphy.gif',
  ),
  NetworkAsset(
    name: 'Truck',
    url: 'https://media.giphy.com/media/xTiTnxpQ3ghPiB2Hp6/giphy.gif',
  ),
];
