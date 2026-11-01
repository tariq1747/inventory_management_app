class Customer {
  int? id;
  String name;
  String? contact;
  String? address;
  String? createdAt;
  String? updatedAt;

  Customer({
    this.id,
    required this.name,
    this.contact,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'address': address,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      name: map['name'],
      contact: map['contact'],
      address: map['address'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
