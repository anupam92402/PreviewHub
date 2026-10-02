# PreviewHub

A real-device gallery for your Flutter design system. Preview components, screens, icons, images, fonts, Lottie animations, Rive files, and other assets inside your own app.

Everything is rendered using the same Flutter engine, theme, assets, and runtime configuration used by your application.

No code generation. No `build_runner`. No custom tooling.

| Collections                                                                                                                            | Dark theme                                                                                                                                          | Widgets                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/dashboard.png" alt="Landing screen" width="180"> | <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/dashboard_dark.png" alt="Landing screen in dark" width="180"> | <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_index.png" alt="Widget index" width="180"> |

| Component                                                                                                                                     | Screen                                                                                                                                     |
| --------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_detail.png" alt="Component detail" width="180"> | <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/widgets_stage.png" alt="Screen preview" width="180"> |

## Requirements

Flutter **3.44 or newer**.

PreviewHub keeps dependencies to a minimum and currently uses `flutter_svg`, `http`, `lottie`, and `rive`. `rive` ships platform binaries, making it the heaviest dependency.

## Install

```yaml
dependencies:
  preview_hub: ^0.0.1
```

## Use

Push `PreviewHubDashboard` from anywhere in your app, preferably behind `kDebugMode` or your own development flag.

```dart
import 'package:flutter/foundation.dart';
import 'package:preview_hub/preview_hub.dart';

if (kDebugMode) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (BuildContext context) => const PreviewHubDashboard(
        config: PreviewHubConfig(
          widgets: previewWidgets,
          networkImages: <String>[
            'https://example.com/logo.svg',
          ],
          networkLotties: <String>[
            'https://example.com/loader.json',
          ],
          networkRives: <String>[
            'https://example.com/rating.riv',
          ],
        ),
      ),
    ),
  );
}
```

Since `kDebugMode` is a compile-time constant, PreviewHub can be tree-shaken from release builds rather than simply hidden at runtime.

> Gating PreviewHub removes its Dart code, but native libraries brought by dependencies such as `rive` may still be packaged with the application.

## Registering widgets

A widget is code rather than an asset, so it cannot be discovered through a manifest. Use `WidgetPreview.component` for individual components and `WidgetPreview.screen` for complete screens.

```dart
const List<WidgetPreview> previewWidgets = <WidgetPreview>[
  WidgetPreview.component(
    group: 'Buttons',
    title: 'AppButton · primary',
    cases: <WidgetPreviewCase>[
      WidgetPreviewCase(
        label: 'filled · large (52)',
        builder: _primaryLarge,
      ),
      WidgetPreviewCase(
        label: 'disabled',
        builder: _primaryDisabled,
      ),
    ],
  ),
  WidgetPreview.screen(
    group: 'Auth',
    title: 'SignInScreen',
    builder: _signIn,
  ),
];

Widget _primaryLarge(BuildContext context) =>
    AppButton(
      label: 'Continue',
      size: AppButtonSize.large,
      onPressed: () {},
    );
```

`group` defines the collapsible heading and `title` defines the preview name. Components can contain multiple cases, while screens open as full-size previews.

Builders run only when a preview is displayed.

## Collections

The landing screen provides global search and recently viewed items for quickly navigating through the gallery.

| Collection         | Contents                                                                                                                            |
| ------------------ | ----------------------------------------------------------------------------------------------------------------------------------- |
| **Widgets**        | Registered components and screens, grouped and searchable.                                                                          |
| **Icons & Images** | SVG, PNG, WebP, JPEG and GIF with dimensions and file size. Icon and image previews support different sizes, backgrounds, and tint. |
| **Fonts**          | Font families and weights from the font manifest with size previews and a type tester.                                              |
| **Lottie**         | Bundled and remote JSON animations with duration and frame count.                                                                   |
| **Rive**           | Bundled and remote `.riv` files with artboard and state machine information.                                                        |
| **Other**          | Additional assets such as PDF, JSON, and audio files.                                                                               |

| Icons & Images                                                                                                                       | Fonts                                                                                                                     |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/icons.png" alt="Icons and images" width="180"> | <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/fonts.png" alt="Fonts" width="180"> |

| Lottie                                                                                                                      | Rive                                                                                                                    |
| --------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/lottie.png" alt="Lottie" width="180"> | <img src="https://raw.githubusercontent.com/anupam92402/PreviewHub/master/screenshots/rive.png" alt="Rive" width="180"> |

The landing screen also provides an asset size breakdown to visualise the size contribution of each asset type.

Bundled assets are discovered from Flutter's asset and font manifests, so they don't need to be registered manually. Remote assets are validated before being displayed.

## Why PreviewHub?

A design system can look different on a real device because of text scale, fonts, pixel density, themes, and runtime behaviour.

PreviewHub puts your design system inside your own app, allowing you to browse and validate components and assets using the real Flutter engine and the same application environment.

## Why not IDE previews?

IDE previews are great for individual widgets during development. PreviewHub focuses on browsing an entire design system on a real device, with the same rendering engine, fonts, assets, theme, and runtime behaviour used by your application.

## Example

The `example/` directory contains a small design system with five components, seven screens, and a real asset set.

```sh
cd example
flutter run
```

## License

MIT. See [LICENSE](LICENSE).
