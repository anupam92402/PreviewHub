# preview_hub_example

An ordinary client app that opens the `preview_hub` gallery from a debug-only
button, so the gallery has something real to show.

It carries its own small design system, in `lib/design_system`:

- `AppButton`, in three tones, three variants and three heights
- `AppCheckbox`, with tristate, helper and error states
- `AppTextField`, drawing its own focus, error and disabled states
- `AppToast`, in success, failure and pending flavours
- `GradientText`

Seven screens in `lib/screens` are built from those pieces: sign-in, success,
dashboard, settings, profile, history and notifications. All of them are
registered in `lib/preview_widgets.dart`, which is the file to read to see how
a host app hands its widgets to the gallery.

It also bundles a real asset set for the other four collections: 25 images
across five formats, three font families, five Lottie animations and five Rive
files, with remote URLs listed in `network_assets.dart`, `network_lotties.dart`
and `network_rives.dart`.

```sh
flutter run
```

Then tap the Preview Hub button. It appears only in debug builds, gated on
`kDebugMode`.
