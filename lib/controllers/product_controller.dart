import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';
import '../repositories/stock_movement_repository.dart';

class ProductController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final StockMovementRepository _stockRepo = StockMovementRepository();

  var products = <Product>[].obs;
  var selecetdProduct = Rxn<Product>();
  var lowStockProducts = <Product>[].obs;
  var isLoading = false.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadLowStockProducts();
  }

  Future<void> loadProducts() async {
    isLoading.value = true;
    try {
      products.value = await _productRepo.getAllProducts();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLowStockProducts() async {
    try {
      lowStockProducts.value = await _productRepo.getLowStockProducts();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> searchProducts(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      await loadProducts();
    } else {
      isLoading.value = true;
      try {
        products.value = await _productRepo.searchProducts(query);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to search products',
          backgroundColor: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productRepo.insertProduct(product);
      await loadProducts();
      await loadLowStockProducts();
      Get.snackbar(
        'Success',
        'Product added successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add product',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _productRepo.updateProduct(product);
      await loadProducts();
      await loadLowStockProducts();
      Get.snackbar(
        'Success',
        'Product updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _productRepo.deleteProduct(id);
      await loadProducts();
      await loadLowStockProducts();
      Get.snackbar(
        'Success',
        'Product deleted successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateStock(
    int productId,
    int newQuantity,
    String reason,
  ) async {
    try {
      final product = products.firstWhere((p) => p.id == productId);
      final difference = newQuantity - product.quantity;

      if (difference > 0) {
        await _stockRepo.recordStockIn(productId, difference, reason);
      } else if (difference < 0) {
        await _stockRepo.recordStockOut(productId, -difference, reason);
      }

      await _productRepo.updateProductQuantity(productId, newQuantity);
      await loadProducts();
      await loadLowStockProducts();
      Get.snackbar(
        'Success',
        'Stock updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update stock',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<double> getTotalStockValue() async {
    return await _productRepo.getTotalStockValue();
  }
}
