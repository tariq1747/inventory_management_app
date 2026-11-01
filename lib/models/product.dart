class Product {
  int? id;
  String name;
  String? sku;
  String? barcode;
  int? categoryId;
  double purchasePrice;
  double sellingPrice;
  int quantity;
  int? supplierId;
  int lowStockThreshold;
  String? createdAt;
  String? updatedAt;

  // Relations
  String? categoryName;
  String? supplierName;

  Product({
    this.id,
    required this.name,
    this.sku,
    this.barcode,
    this.categoryId,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    this.supplierId,
    this.lowStockThreshold = 10,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.supplierName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'supplier_id': supplierId,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      barcode: map['barcode'],
      categoryId: map['category_id'],
      purchasePrice: map['purchase_price'],
      sellingPrice: map['selling_price'],
      quantity: map['quantity'],
      supplierId: map['supplier_id'],
      lowStockThreshold: map['low_stock_threshold'] ?? 10,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      categoryName: map['category_name'],
      supplierName: map['supplier_name'],
    );
  }

  bool get isLowStock => quantity <= lowStockThreshold;

  double get profitMargin => sellingPrice - purchasePrice;
}
