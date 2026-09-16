# preview_hub

A real-device gallery for your Flutter design system. Preview components, screens, icons, images,
fonts, Lottie animations, and Rive files inside your own app. Everything is rendered by the same 
Flutter engine, theme, assets, and runtime configuration used by your application.  No code generation. 
No build_runner. No custom tooling.

| Collections | Widgets | One component | One screen |
| --- | --- | --- | --- |
| ![Landing screen](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/dashboard.png) | ![Widget index](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_index.png) | ![Component detail](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_detail.png) | ![Screen preview](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_stage.png) |

## Requirements

Flutter 3.44 or newer. The package depends on `flutter_svg`, `http`, `lottie`
and `rive`; `rive` ships platform binaries, so it is the heaviest of the four.

## Install

```yaml
dependencies:
  preview_hub: ^0.0.1
```

## Use

Push `PreviewHubDashboard` from anywhere in your app, behind `kDebugMode`.
It is a compile-time constant, so the gallery is tree-shaken out of a release
build rather than merely hidden.

```dart
import 'package:flutter/foundation.dart';
import 'package:preview_hub/preview_hub.dart';

if (kDebugMode) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const PreviewHubDashboard(
        config: PreviewHubConfig(
          widgets: previewWidgets,
          networkImages: <String>['https://example.com/logo.svg'],
          networkLotties: <String>['https://example.com/loader.json'],
          networkRives: <String>['https://example.com/rating.riv'],
        ),
      ),
    ),
  );
}
```

Bundled assets are found in the asset and font manifests and never need
registering, so the config carries only the remote URLs and the widgets. A URL
that cannot be used is ignored rather than thrown over.

The gallery carries its own theme and its own light and dark toggle, so it does
not inherit or disturb your app's.

Gating removes the Dart code, not the native libraries the dependencies bring:
`rive` ships a prebuilt binary that is packaged whether or not the gallery can
be reached.

## Registering widgets

A widget is code, not an asset, so there is no manifest to read. Use
`WidgetPreview.component` for a piece of the design system and
`WidgetPreview.screen` for a whole screen.

```dart
const List<WidgetPreview> previewWidgets = <WidgetPreview>[
  WidgetPreview.component(
    group: 'Buttons',
    title: 'AppButton · primary',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(label: 'filled · large (52)', builder: _primaryLarge),
      WidgetPreviewCase(label: 'disabled', builder: _primaryDisabled),
    ],
  ),
  WidgetPreview.screen(
    group: 'Auth',
    title: 'SignInScreen',
    builder: _signIn,
  ),
];

Widget _primaryLarge(BuildContext context) =>
    AppButton(label: 'Continue', size: AppButtonSize.large, onPressed: () {});
```

`group` is the collapsible heading and `title` is the whole name. A component
lists each of its `cases` down one page, with the label above the rendering it
describes. A screen opens full size. Builders run only when a preview is on
screen.

## Why

A design system looks fine in a design file and fine in a browser. What matters
is how it looks on the handset your users actually hold, with their text scale,
their theme and their pixel density. `preview_hub` puts that catalogue inside
your own app, so every preview runs through the real Flutter engine on the real
device.

## Why not IDE previews?

IDE previews are great for individual widgets during development.
preview_hub focuses on browsing an entire design system on a real device,
with the same rendering engine, fonts, assets, theme and runtime behavior
used by your application.

## What each collection shows

| Collection | Contents |
| --- | --- |
| Widgets | Registered components and screens, grouped, searchable, folded by default |
| Icons & Images | SVG, PNG, WebP, JPEG and GIF, with pixel size and byte size per asset |
| Fonts | Every family and weight from the font manifest, set on an 8 to 32 size ramp, plus a type tester for your own words |
| Lottie | Bundled and remote JSON animations, playing in the grid, with duration and frame count |
| Rive | Bundled and remote `.riv` files, with artboard and state machine |

The four asset collections measure what they list. Bundled entries are read
from the bundle, remote ones through a `HEAD` request that falls back to a
`GET`, and every remote entry is checked so the screen can report which ones
could not be used.

| Icons & Images | Fonts | Lottie | Rive |
| --- | --- | --- | --- |
| ![Icons and images](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/icons.png) | ![Fonts](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/fonts.png) | ![Lottie](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/lottie.png) | ![Rive](https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/rive.png) |

## Example

The `example/` directory is an ordinary client app with its own small design
system, five components and seven screens, plus a real asset set. It is the
fastest way to see what a populated gallery looks like:

```sh
cd example
flutter run
```

## License

MIT. See [LICENSE](LICENSE).
