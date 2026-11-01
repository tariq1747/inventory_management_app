import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/models/product.dart';
import 'package:inventory_management_app/repositories/product_repository.dart';
import '../models/stock_movement.dart';
import '../repositories/stock_movement_repository.dart';

class StockMovementController extends GetxController {
  final StockMovementRepository _stockMovementRepo = StockMovementRepository();
  final ProductRepository _productRepo = ProductRepository();

  var stockMovements = <StockMovement>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStockMovements();
  }

  Future<void> loadStockMovements() async {
    isLoading.value = true;
    try {
      stockMovements.value = await _stockMovementRepo.getAllStockMovements();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load stock movements',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getProductStockMovements(int productId) async {
    isLoading.value = true;
    try {
      stockMovements.value = await _stockMovementRepo
          .getStockMovementsByProduct(productId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load stock movements',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordStockIn(
    Product selectedProduct,
    int quantity,
    String reason,
  ) async {
    try {
      await _stockMovementRepo.recordStockIn(
        selectedProduct.id!,
        quantity,
        reason,
      );
      final newQuantity = selectedProduct.quantity + quantity;

      await _productRepo.updateProductQuantity(
        selectedProduct.id!,
        newQuantity,
      );

      await loadStockMovements();
      Get.snackbar(
        'Success',
        'Stock in recorded successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record stock in',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> recordStockOut(
    Product selectedProduct,
    int quantity,
    String reason,
  ) async {
    try {
      await _stockMovementRepo.recordStockOut(
        selectedProduct.id!,
        quantity,
        reason,
      );

      final newQuantity = selectedProduct.quantity - quantity;

      await _productRepo.updateProductQuantity(
        selectedProduct.id!,
        newQuantity,
      );
      await loadStockMovements();
      Get.snackbar(
        'Success',
        'Stock out recorded successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to record stock out',
        backgroundColor: Colors.white,
      );
    }
  }
}
