/// Every user-facing string on the landing screen.
class PreviewHubStrings {
  const PreviewHubStrings._();

  /// Capsule above the headline.
  static const String badgeLabel = 'PREVIEW HUB';

  /// Headline.
  static const String headline = 'See your design system\nrunning for real.';

  /// Line under the headline.
  static const String subhead =
      'Components, screens, icons, type and motion — rendered exactly the way '
      'your users will get them.';

  /// Heading above the section list.
  static const String listLabel = 'COLLECTIONS';

  /// Closing nudge under the section list.
  static const String footnote =
      'Every preview runs on the device in your hand, at the size your users '
      'will see it.';

  /// Tooltip on the theme toggle while the dark theme is showing.
  static const String themeToggleToLight = 'Switch to light mode';

  /// Tooltip on the theme toggle while the light theme is showing.
  static const String themeToggleToDark = 'Switch to dark mode';

  /// Title of the widget preview section.
  static const String sectionWidgetsTitle = 'Widgets';

  /// Summary of the widget preview section.
  static const String sectionWidgetsDescription =
      'Every component and screen you register, running full size.';

  /// Placeholder in the widget search field.
  static const String searchWidgetsHint = 'Filter by widget or group';

  /// Shown when no widget matches the search and chips.
  static const String emptyWidgets = 'Nothing matches those filters';

  /// Shown when the host registered no widgets at all.
  static const String emptyWidgetsUnregistered =
      'No widgets were registered.\nPass them to PreviewHubConfig.widgets.';

  /// Says how many renderings an entry holds.
  static String widgetCaseCount(int count) =>
      '$count ${count == 1 ? 'preview' : 'previews'}';

  /// Tooltip on the button closing a full-screen preview.
  static const String widgetStageClose = 'Close preview';

  /// Title of the icons and images section.
  static const String sectionIconsAndImagesTitle = 'Icons & Images';

  /// Summary of the icons and images section.
  static const String sectionIconsAndImagesDescription =
      'SVG, PNG, WebP, JPEG and GIF, bundled or straight off the network.';

  /// Placeholder in the asset search field.
  static const String searchAssetsHint = 'Search name or path';

  /// Shown when no asset matches the search and filters.
  static const String emptyAssets = 'Nothing matches those filters';

  /// Title of the validation report sheet.
  static const String validationReportTitle = 'Validation report';

  /// Shown in the report when nothing went wrong.
  static const String validationReportEmpty = 'Every entry loaded cleanly.';

  /// Says how many entries the report covers.
  static String validationReportChecked(int count) => count == 0
      ? 'No remote entries were supplied.'
      : '$count remote ${count == 1 ? 'entry was' : 'entries were'} checked.';

  /// Tooltip on the report button.
  static const String validationReportTooltip = 'Validation report';

  /// Summary line above the list of [count] problems.
  static String validationReportSummary(int count) =>
      '$count ${count == 1 ? 'entry' : 'entries'} could not be used as '
      'supplied.';

  /// Caption on a tile whose artwork could not be drawn.
  static const String assetLoadFailed = 'Some Error Occurred';

  /// Reason shown when an asset failed with no recorded cause.
  static const String assetCannotDisplay = 'This file could not be displayed';

  /// Stands in for the size and dimensions of a failed asset.
  static const String assetUnavailable = 'Unavailable';

  /// Heading above the column choices in the view menu.
  static const String viewColumnsLabel = 'Per row';

  /// Names the choice that puts [count] tiles in a row.
  static String viewColumns(int count) => '$count per row';

  /// Words every font sample is set in.
  static const String fontSampleText =
      'The quick brown fox jumps over the lazy dog';

  /// Heading above one face's size ramp.
  static String fontWeightHeading(int weight) => 'Weight $weight';

  /// Marks an italic cut in a weight heading.
  static const String fontItalicSuffix = 'Italic';

  /// Title of the screen where a consumer writes their own sample.
  static const String fontSampleTitle = 'Custom text';

  /// Tooltip on the button that opens it.
  static const String fontSampleTooltip = 'Try your own text';

  /// Heading of the checklist shown before anything is chosen.
  static const String fontSampleChecklist = 'Pick all three to start writing';

  /// Label of the family field.
  static const String fontFieldFamily = 'Family';

  /// Label of the weight field.
  static const String fontFieldWeight = 'Weight';

  /// Label of the size field.
  static const String fontFieldSize = 'Size';

  /// Label of the text field.
  static const String fontFieldText = 'Your text';

  /// Placeholder in the text field.
  static const String fontTextHint = 'Type or paste something';

  /// Explains why the text field is not ready yet.
  static String fontSampleLocked(List<String> missing) {
    final List<String> names = missing
        .map((String name) => name.toLowerCase())
        .toList();
    final String joined = names.length == 1
        ? names.single
        : '${names.sublist(0, names.length - 1).join(', ')} and ${names.last}';
    return 'Choose a $joined to start writing';
  }

  /// Sits under the preview, naming what it is set in.
  static String fontSampleCaption(String family, String face, double size) =>
      '$family · $face · ${size.toInt()}';

  /// Stands in for the sample before anything is typed.
  static const String fontSamplePlaceholder = 'Your text appears here';

  /// Title of the family chip row.
  static const String fontFamilyFilterLabel = 'Family';

  /// Placeholder in the font search field.
  static const String searchFontsHint = 'Search family';

  /// Shown when no family matches the search.
  static const String emptyFonts = 'No family matches that search';

  /// Says how many faces a family ships.
  static String fontFaceCount(int count) =>
      '$count ${count == 1 ? 'face' : 'faces'}';

  /// Tooltip on the sort button.
  static const String sortTooltip = 'Sort by size';

  /// Title of the source filter row.
  static const String filterSourceLabel = 'Source';

  /// Title of the format filter row.
  static const String filterTypeLabel = 'Type';

  /// Filter chip that clears its whole row.
  static const String filterAll = 'All';

  /// Detail row labels.
  static const String detailName = 'Name';

  /// Label for the format row.
  static const String detailType = 'Type';

  /// Label for the origin row.
  static const String detailSource = 'Source';

  /// Label for the pixel size row.
  static const String detailDimensions = 'Dimensions';

  /// Label for the byte size row.
  static const String detailSize = 'Size';

  /// Label for the manifest key row.
  static const String detailPath = 'Path';

  /// Label for the URL row.
  static const String detailUrl = 'URL';

  /// Label for the failure row.
  static const String detailError = 'Error';

  /// Shown in place of a size while it is still being measured.
  static const String measuring = 'Measuring…';

  /// Shown in place of a size that could not be measured.
  static const String unknown = 'Unknown';

  /// Placeholder in the Lottie search field.
  static const String searchLottieHint = 'Search name or path';

  /// Shown when no animation matches the search and filters.
  static const String emptyLottie = 'Nothing matches those filters';

  /// Caption on an animation that could not be played.
  static const String lottieFailed = 'Not a playable Lottie';

  /// Tooltip on the button that pauses an animation.
  static const String lottiePause = 'Pause';

  /// Tooltip on the button that resumes an animation.
  static const String lottiePlay = 'Play';

  /// Tooltip on the button that plays an animation from the start.
  static const String lottieRestart = 'Restart';

  /// How long an animation runs, as `1.5s`.
  static String lottieDuration(Duration duration) =>
      '${(duration.inMilliseconds / 1000).toStringAsFixed(1)}s';

  /// Label of the animation's running time.
  static const String lottieDetailDuration = 'Duration';

  /// Label of the animation's frame count and rate.
  static const String lottieDetailFrames = 'Frames';

  /// Placeholder in the Rive search field.
  static const String searchRiveHint = 'Search name or path';

  /// Shown when no animation matches the search and filters.
  static const String emptyRive = 'Nothing matches those filters';

  /// Caption on an animation that could not be played.
  static const String riveFailed = 'Not a playable Rive file';

  /// Label of the artboard row.
  static const String riveDetailArtboard = 'Artboard';

  /// Label of the state machine row.
  static const String riveDetailStateMachine = 'State machine';

  /// Stands in for a file with no state machine.
  static const String riveNoStateMachine = 'None';

  /// Tooltip on a button that empties a field.
  static const String clear = 'Clear';

  /// Tooltip on the copy button.
  static const String copy = 'Copy';

  /// Confirmation after copying.
  static const String copied = 'Copied';

  /// Title of the fonts section.
  static const String sectionFontsTitle = 'Fonts';

  /// Summary of the fonts section.
  static const String sectionFontsDescription =
      'Every family and weight, set at the sizes you actually ship.';

  /// Title of the Lottie section.
  static const String sectionLottieTitle = 'Lottie';

  /// Summary of the Lottie section.
  static const String sectionLottieDescription =
      'JSON motion, playing at full speed on real hardware.';

  /// Title of the Rive section.
  static const String sectionRiveTitle = 'Rive';

  /// Summary of the Rive section.
  static const String sectionRiveDescription =
      'Animations and state machines, live and interactive.';
}
