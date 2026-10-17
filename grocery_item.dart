class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.quantity = 1,
    this.unit = 'pcs',
    this.price = 0,
    this.packSize = 1,
  });

  final String id;
  final String name;
  final String emoji;

  /// Number of selected packs/units in the cart.
  final int quantity;

  /// The unit the estimate is based on: kg, L, dozen, bunch, pack, or pcs.
  final String unit;

  /// Approximate local-market price per [unit], in INR. Not a live store price.
  final int price;

  /// For kg-based items, kilograms per pack (for example, 1 kg or 10 kg).
  /// For other units this remains 1.
  final int packSize;

  GroceryItem copyWith({int? quantity, int? packSize}) {
    return GroceryItem(
      id: id,
      name: name,
      emoji: emoji,
      quantity: quantity ?? this.quantity,
      unit: unit,
      price: price,
      packSize: packSize ?? this.packSize,
    );
  }

  int get lineTotal => price * quantity * (unit == 'kg' ? packSize : 1);

  String get unitLabel => switch (unit) {
        'kg' => 'kg',
        'L' => 'L',
        'dozen' => 'dozen',
        'bunch' => 'bunch',
        'pack' => 'pack',
        _ => 'pcs',
      };
}
