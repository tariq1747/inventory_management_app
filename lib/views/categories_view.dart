import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';
import '../models/category.dart';

class CategoriesView extends StatelessWidget {
  final CategoryController categoryCtrl = Get.find<CategoryController>();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: Obx(() {
        if (categoryCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: categoryCtrl.loadCategories,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: categoryCtrl.categories.length,
            itemBuilder: (context, index) {
              final category = categoryCtrl.categories[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(category.name),
                  subtitle: Text(category.description ?? 'No description'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text('Edit'), value: 'edit'),
                      PopupMenuItem(child: Text('Delete'), value: 'delete'),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCategoryDialog(context, category);
                      } else if (value == 'delete') {
                        categoryCtrl.deleteCategory(category.id!);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, [Category? category]) {
    nameController.text = category?.name ?? '';
    descController.text = category?.description ?? '';

    Get.dialog(
      AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Category Name *'),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter category name',
                  backgroundColor: Colors.white,
                );
                return;
              }

              final newCategory = Category(
                id: category?.id,
                name: nameController.text,
                description: descController.text.isEmpty
                    ? null
                    : descController.text,
              );

              if (category == null) {
                categoryCtrl.addCategory(newCategory);
              } else {
                categoryCtrl.updateCategory(newCategory);
              }
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}
