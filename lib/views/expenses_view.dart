import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../models/expense.dart';

class ExpensesView extends StatefulWidget {
  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final ExpenseController expenseCtrl = Get.find<ExpenseController>();

  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expenses'), elevation: 0),
      body: Obx(() {
        if (expenseCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (expenseCtrl.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No expenses recorded yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 100),
          itemCount: expenseCtrl.expenses.length,
          itemBuilder: (context, index) {
            final expense = expenseCtrl.expenses[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.description,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Category: ${expense.category ?? "General"} • ${expense.date ?? "N/A"}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('Edit'),
                              onTap: () {
                                Future.delayed(Duration.zero, () {
                                  _showExpenseDialog(context, expense: expense);
                                });
                              },
                            ),
                            PopupMenuItem(
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              onTap: () {
                                _confirmDelete(context, expense.id!);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showExpenseDialog(context),
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, {Expense? expense}) {
    descriptionController.clear();
    amountController.clear();
    categoryController.clear();

    if (expense != null) {
      descriptionController.text = expense.description;
      amountController.text = expense.amount.toString();
      categoryController.text = expense.category ?? '';
    }

    Get.dialog(
      AlertDialog(
        title: Text(expense == null ? 'Add Expense' : 'Edit Expense'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              final amount = double.tryParse(amountController.text) ?? 0;
              final category = categoryController.text.trim();

              if (description.isEmpty || amount <= 0) {
                Get.snackbar('Error', 'Please fill all fields correctly');
                return;
              }

              if (expense == null) {
                final newExpense = Expense(
                  description: description,
                  amount: amount,
                  category: category.isEmpty ? null : category,
                  date: DateTime.now().toString().split(' ')[0],
                );
                expenseCtrl.addExpense(newExpense);
              } else {
                final updatedExpense = Expense(
                  id: expense.id,
                  description: description,
                  amount: amount,
                  category: category.isEmpty ? null : category,
                  date: expense.date,
                );
                expenseCtrl.updateExpense(updatedExpense);
              }

              Get.back();
            },
            child: Text(expense == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              expenseCtrl.deleteExpense(id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
