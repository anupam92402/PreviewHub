/// How the grid is ordered.
enum AssetSortOrder {
  /// Manifest order: bundled assets by key, then remote ones as supplied.
  none('Default order'),

  /// Smallest files first.
  sizeAsc('Size: low to high'),

  /// Largest files first.
  sizeDesc('Size: high to low');

  const AssetSortOrder(this.label);

  /// Name shown in the sort menu.
  final String label;

  /// Whether this order needs every asset measured before it can be applied.
  bool get needsSizes => this != none;
}
