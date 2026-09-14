/// Every user-facing string on the landing screen.
class PreviewHubStrings {
  const PreviewHubStrings._();

  /// Capsule above the headline.
  static const String badgeLabel = 'PREVIEW HUB';

  /// Headline.
  static const String headline = 'See your design system\nrunning for real.';

  /// Line under the headline.
  static const String subhead =
      'Local and network assets — icons, type and motion — rendered exactly '
      'the way your users will get them.';

  /// Heading above the section list.
  static const String listLabel = 'COLLECTIONS';

  /// Closing nudge under the section list.
  static const String footnote =
      'Pick a collection and start exploring — every preview runs on the '
      'device in your hand.';

  /// Tooltip on the theme toggle while the dark theme is showing.
  static const String themeToggleToLight = 'Switch to light mode';

  /// Tooltip on the theme toggle while the light theme is showing.
  static const String themeToggleToDark = 'Switch to dark mode';

  /// Title of the widget preview section.
  static const String sectionWidgetsTitle = 'Widgets';

  /// Summary of the widget preview section.
  static const String sectionWidgetsDescription =
      'Every `@Preview` builder, searchable and running full screen.';

  /// Title of the icons and images section.
  static const String sectionIconsAndImagesTitle = 'Icons & Images';

  /// Summary of the icons and images section.
  static const String sectionIconsAndImagesDescription =
      'SVG and PNG artwork, bundled or straight off the network.';

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
