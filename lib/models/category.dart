class Category {
  int? id;
  String name;
  String? description;
  String? createdAt;
  String? updatedAt;

  Category({
    this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
