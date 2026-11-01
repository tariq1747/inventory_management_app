import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class CategoryController extends GetxController {
  final CategoryRepository _categoryRepo = CategoryRepository();

  var categories = <Category>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.value = await _categoryRepo.getAllCategories();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load categories',
        backgroundColor: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _categoryRepo.insertCategory(category);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category added successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add category',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _categoryRepo.updateCategory(category);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category updated successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update category',
        backgroundColor: Colors.white,
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _categoryRepo.deleteCategory(id);
      await loadCategories();
      Get.snackbar(
        'Success',
        'Category deleted successfully',
        backgroundColor: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete category',
        backgroundColor: Colors.white,
      );
    }
  }
}
