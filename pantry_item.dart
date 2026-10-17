class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.quantity = 1,
    this.unit = 'pcs',
    this.displayName,
  });

  /// Canonical ingredient name used for recipe matching.
  final String name;
  /// Localized label shown to the user, without changing the canonical key.
  final String? displayName;
  final String id;
  final String emoji;
  final int quantity;
  final String unit;

  String get key => name.trim().toLowerCase();

  PantryItem copyWith({int? quantity, String? displayName}) {
    return PantryItem(
      id: id,
      name: name,
      emoji: emoji,
      quantity: quantity ?? this.quantity,
      unit: unit,
      displayName: displayName ?? this.displayName,
    );
  }
}
