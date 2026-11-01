class Expense {
  int? id;
  String description;
  double amount;
  String? category;
  String? date;
  String? createdAt;
  String? updatedAt;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    this.category,
    this.date,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
