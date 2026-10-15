class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.emoji,
    this.quantity = 1,
    this.price = 35,
  });

  final String id;
  final String name;
  final String emoji;
  final int quantity;
  final int price;

  GroceryItem copyWith({int? quantity}) {
    return GroceryItem(
      id: id,
      name: name,
      emoji: emoji,
      quantity: quantity ?? this.quantity,
      price: price,
    );
  }

  int get lineTotal => price * quantity;
}
