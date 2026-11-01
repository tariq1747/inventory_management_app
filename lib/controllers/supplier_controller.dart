import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/supplier.dart';
import '../repositories/supplier_repository.dart';

class SupplierController extends GetxController {
  final SupplierRepository _supplierRepo = SupplierRepository();

  var suppliers = <Supplier>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    isLoading.value = true;
    try {
      suppliers.value = await _supplierRepo.getAllSuppliers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load suppliers',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await _supplierRepo.insertSupplier(supplier);
      await loadSuppliers();
      Get.snackbar(
        'Success',
        'Supplier added successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add supplier',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await _supplierRepo.updateSupplier(supplier);
      await loadSuppliers();
      Get.snackbar(
        'Success',
        'Supplier updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update supplier',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await _supplierRepo.deleteSupplier(id);
      await loadSuppliers();
      Get.snackbar(
        'Success',
        'Supplier deleted successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete supplier',
        backgroundColor: Colors.white,
      );
    }
  }
}
