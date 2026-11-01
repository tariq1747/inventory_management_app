import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/product.dart';
import '../repositories/invoice_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/stock_movement_repository.dart';

class InvoiceController extends GetxController {
  final InvoiceRepository _invoiceRepo = InvoiceRepository();
  final ProductRepository _productRepo = ProductRepository();
  final StockMovementRepository _stockRepo = StockMovementRepository();

  var invoices = <Invoice>[].obs;
  var isLoading = false.obs;
  var selectedProducts = <Product>[].obs;
  var invoiceItems = <InvoiceItem>[].obs;

  double subtotal = 0;
  double discount = 0;
  double grandTotal = 0;

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    isLoading.value = true;
    try {
      invoices.value = await _invoiceRepo.getAllInvoices();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load invoices',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addProductToInvoice(Product product, int quantity) {
    final existingIndex = invoiceItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      if ((invoiceItems[existingIndex].quantity + quantity) >
          product.quantity) {
        Future.delayed(Duration(milliseconds: 500), () {
          Get.snackbar(
            'Error',
            'Insufficient stock for ${product.name}',
            backgroundColor: Colors.white,
          );
        });

        return;
      }
      invoiceItems[existingIndex].quantity += quantity;
      invoiceItems[existingIndex].total =
          invoiceItems[existingIndex].quantity *
          invoiceItems[existingIndex].unitPrice;
    } else {
      if (quantity > product.quantity) {
        Future.delayed(Duration(milliseconds: 500), () {
          Get.snackbar(
            'Error',
            'Insufficient stock for ${product.name}',
            backgroundColor: Colors.white,
          );
        });

        return;
      }
      final item = InvoiceItem(
        invoiceId: 0, // Will be set when saving
        productId: product.id!,
        quantity: quantity,
        costPrice: product.purchasePrice,
        unitPrice: product.sellingPrice,
        total: quantity * product.sellingPrice,
        productName: product.name,
      );
      invoiceItems.add(item);
    }
    calculateTotals();
  }

  void removeProductFromInvoice(int index) {
    invoiceItems.removeAt(index);
    calculateTotals();
  }

  void updateItemQuantity(int index, int quantity) {
    if (quantity <= 0) {
      removeProductFromInvoice(index);
      return;
    }
    invoiceItems[index].quantity = quantity;
    invoiceItems[index].total = quantity * invoiceItems[index].unitPrice;
    calculateTotals();
  }

  void calculateTotals() {
    subtotal = invoiceItems.fold(0, (sum, item) => sum + item.total);
    grandTotal = subtotal - discount;
  }

  void setDiscount(double value) {
    discount = value;
    calculateTotals();
  }

  void setTaxRate(double rate) {
    calculateTotals();
  }

  Future<void> createInvoice({int? customerId}) async {
    if (invoiceItems.isEmpty) {
      Get.snackbar(
        'Error',
        'Please add products to the invoice',
        backgroundColor: Colors.white,
      );
      return;
    }

    try {
      final invoiceNumber = await _invoiceRepo.generateInvoiceNumber();
      final invoice = Invoice(
        invoiceNumber: invoiceNumber,
        customerId: customerId,
        subtotal: subtotal,
        discount: discount,
        grandTotal: grandTotal,
        createdAt: DateTime.now().toString(),
        updatedAt: DateTime.now().toString(),
      );

      final invoiceId = await _invoiceRepo.insertInvoice(invoice);

      // Update invoice items with correct invoice ID
      for (var item in invoiceItems) {
        item.invoiceId = invoiceId;
      }
      await _invoiceRepo.insertInvoiceItems(invoiceItems);

      // Deduct stock
      for (var item in invoiceItems) {
        final product = await _productRepo.getProductById(item.productId);
        if (product != null) {
          final newQuantity = product.quantity - item.quantity;
          await _productRepo.updateProductQuantity(item.productId, newQuantity);
          await _stockRepo.recordStockOut(
            item.productId,
            item.quantity,
            'Sale - Invoice $invoiceNumber',
          );
        }
      }

      // Clear current invoice
      clearInvoice();
      await loadInvoices();
      Get.snackbar(
        'Success',
        'Invoice created successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      log('Error creating invoice: $e');
      Get.snackbar(
        'Error',
        'Failed to create invoice',
        backgroundColor: Colors.white,
      );
    }
  }

  void clearInvoice() {
    selectedProducts.clear();
    invoiceItems.clear();
    subtotal = 0;
    discount = 0;
    grandTotal = 0;
  }

  Future<Invoice?> getInvoiceById(int id) async {
    return await _invoiceRepo.getInvoiceById(id);
  }

  Future<void> deleteInvoice(int id) async {
    await _invoiceRepo.deleteInvoice(id);
    await loadInvoices();
  }

  Future<double> getTotalSales({String? period}) async {
    return await _invoiceRepo.getTotalSales(period: period);
  }

  Future<List<Invoice>> getMonthlyInvoices() async {
    return await _invoiceRepo.getMonthlyInvoices();
  }

  Future<List<InvoiceItem>> getInvoiceItems(int id) async {
    return await _invoiceRepo.getInvoiceItems(id);
  }
}
