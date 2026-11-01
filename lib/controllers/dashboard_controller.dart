import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_controller.dart';
import 'invoice_controller.dart';
import '../repositories/expense_repository.dart';

class DashboardController extends GetxController {
  late ProductController _productCtrl;
  late InvoiceController _invoiceCtrl;
  late ExpenseRepository _expenseRepo;

  var totalStockValue = 0.0.obs;
  var todaySales = 0.0.obs;
  var monthlySales = 0.0.obs;
  var monthlyProfit = 0.0.obs;
  var lowStockCount = 0.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    loadDashboardData();
  }

  void _initializeControllers() {
    _productCtrl = Get.find<ProductController>();
    _invoiceCtrl = Get.find<InvoiceController>();
    _expenseRepo = ExpenseRepository();
  }

  Future<double> _calculateMonthlyCOGS() async {
    // Get all invoices for the current month
    final monthlyInvoices = await _invoiceCtrl.getMonthlyInvoices();
    double totalCOGS = 0.0;

    for (var invoice in monthlyInvoices) {
      final items = await _invoiceCtrl.getInvoiceItems(invoice.id!);
      // Calculate COGS for each invoice item (cost price × quantity)
      for (var item in items) {
        totalCOGS += (item.costPrice) * item.quantity;
      }
    }

    return totalCOGS;
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      totalStockValue.value = await _productCtrl.getTotalStockValue();
      todaySales.value = await _invoiceCtrl.getTotalSales(period: 'today');
      monthlySales.value = await _invoiceCtrl.getTotalSales(period: 'month');
      lowStockCount.value = _productCtrl.lowStockProducts.length;

      // Calculate monthly profit
      final monthlyExpenses = await _expenseRepo.getTotalExpenses(
        period: 'month',
      );

      // Calculate COGS (Cost of Goods Sold) from invoices
      final monthlyCOGS = await _calculateMonthlyCOGS();

      // Profit = Sales - COGS - Expenses
      monthlyProfit.value = monthlySales.value - monthlyCOGS - monthlyExpenses;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
