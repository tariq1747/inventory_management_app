class InvoiceItem {
  int? id;
  int invoiceId;
  int productId;
  int quantity;
  double unitPrice;
  double costPrice;
  double total;

  // Relations
  String? productName;

  InvoiceItem({
    this.id,
    required this.invoiceId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.total,
    this.productName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'total': total,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'],
      invoiceId: map['invoice_id'],
      productId: map['product_id'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      costPrice: map['cost_price'],
      total: map['total'],
      productName: map['product_name'],
    );
  }
}
