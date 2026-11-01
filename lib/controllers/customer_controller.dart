import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerController extends GetxController {
  final CustomerRepository _customerRepo = CustomerRepository();

  var customers = <Customer>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    try {
      customers.value = await _customerRepo.getAllCustomers();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load customers',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await _customerRepo.insertCustomer(customer);
      await loadCustomers();
      Get.snackbar(
        'Success',
        'Customer added successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add customer',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _customerRepo.updateCustomer(customer);
      await loadCustomers();
      Get.snackbar(
        'Success',
        'Customer updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update customer',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await _customerRepo.deleteCustomer(id);
      await loadCustomers();
      Get.snackbar(
        'Success',
        'Customer deleted successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete customer',
        backgroundColor: Colors.white,
      );
    }
  }
}
