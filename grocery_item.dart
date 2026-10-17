class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.quantity = 1,
    this.unit = 'pcs',
    this.price = 0,
  });

  final String id;
  final String name;
  final String emoji;

  /// Number of selected units (for example, 2 means 2 kg when unit == 'kg').
  final int quantity;

  /// The unit the estimate is based on: kg, L, dozen, bunch, pack, or pcs.
  final String unit;

  /// Approximate local-market price per [unit], in INR. This is not a live store price.
  final int price;

  GroceryItem copyWith({int? quantity}) {
    return GroceryItem(
      id: id,
      name: name,
      emoji: emoji,
      quantity: quantity ?? this.quantity,
      unit: unit,
      price: price,
    );
  }

  int get lineTotal => price * quantity;

  String get unitLabel => switch (unit) {
        'kg' => 'kg',
        'L' => 'L',
        'dozen' => 'dozen',
        'bunch' => 'bunch',
        'pack' => 'pack',
        _ => 'pcs',
      };
}