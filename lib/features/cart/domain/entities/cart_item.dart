class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final int qty;
  final dynamic addedAt;
  final int updatedAt;

  const CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.qty,
    this.addedAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          image == other.image &&
          category == other.category &&
          qty == other.qty &&
          addedAt == other.addedAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      image.hashCode ^
      category.hashCode ^
      qty.hashCode ^
      addedAt.hashCode ^
      updatedAt.hashCode;
}
