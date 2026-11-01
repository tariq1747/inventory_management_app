class StockMovement {
  int? id;
  int productId;
  String type; // 'in' or 'out'
  int quantity;
  String? reason;
  String? createdAt;

  // Relations
  String? productName;

  StockMovement({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    this.reason,
    this.createdAt,
    this.productName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'type': type,
      'quantity': quantity,
      'reason': reason,
      'created_at': createdAt,
    };
  }

  factory StockMovement.fromMap(Map<String, dynamic> map) {
    return StockMovement(
      id: map['id'],
      productId: map['product_id'],
      type: map['type'],
      quantity: map['quantity'],
      reason: map['reason'],
      createdAt: map['created_at'],
      productName: map['product_name'],
    );
  }
}
