import 'invoice_item.dart';

class Invoice {
  int? id;
  String invoiceNumber;
  int? customerId;
  double subtotal;
  double discount;
  double grandTotal;
  String? createdAt;
  String? updatedAt;

  // Relations
  String? customerName;
  List<InvoiceItem>? items;

  Invoice({
    this.id,
    required this.invoiceNumber,
    this.customerId,
    required this.subtotal,
    this.discount = 0,
    required this.grandTotal,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'subtotal': subtotal,
      'discount': discount,
      'grand_total': grandTotal,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      invoiceNumber: map['invoice_number'],
      customerId: map['customer_id'],
      subtotal: map['subtotal'],
      discount: map['discount'] ?? 0,
      grandTotal: map['grand_total'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      customerName: map['customer_name'],
    );
  }
}
