class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.quantity = 1,
    this.unit = 'pcs',
  });

  final String id;
  final String name;
  final String emoji;
  final int quantity;
  final String unit;

  String get key => name.trim().toLowerCase();

  PantryItem copyWith({int? quantity}) {
    return PantryItem(
      id: id,
      name: name,
      emoji: emoji,
      quantity: quantity ?? this.quantity,
      unit: unit,
    );
  }
}
