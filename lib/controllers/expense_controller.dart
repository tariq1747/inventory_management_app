import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _expenseRepo = ExpenseRepository();

  var expenses = <Expense>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    isLoading.value = true;
    try {
      expenses.value = await _expenseRepo.getAllExpenses();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load expenses',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseRepo.insertExpense(expense);
      await loadExpenses();
      Get.snackbar(
        'Success',
        'Expense added successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add expense',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _expenseRepo.updateExpense(expense);
      await loadExpenses();
      Get.snackbar(
        'Success',
        'Expense updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update expense',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _expenseRepo.deleteExpense(id);
      await loadExpenses();
      Get.snackbar(
        'Success',
        'Expense deleted successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete expense',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<double> getTotalExpenses({String? period}) async {
    try {
      return await _expenseRepo.getTotalExpenses(period: period);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to calculate total expenses',
        backgroundColor: Colors.white,
      );
      return 0.0;
    }
  }
}
