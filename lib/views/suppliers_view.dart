import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/supplier_controller.dart';
import '../models/supplier.dart';

class SuppliersView extends StatelessWidget {
  final SupplierController supplierCtrl = Get.find<SupplierController>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suppliers')),
      body: Obx(() {
        if (supplierCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: supplierCtrl.loadSuppliers,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: supplierCtrl.suppliers.length,
            itemBuilder: (context, index) {
              final supplier = supplierCtrl.suppliers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(supplier.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${supplier.contact ?? 'N/A'}'),
                      Text('Address: ${supplier.address ?? 'N/A'}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text('Edit'), value: 'edit'),
                      PopupMenuItem(child: Text('Delete'), value: 'delete'),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showSupplierDialog(context, supplier);
                      } else if (value == 'delete') {
                        supplierCtrl.deleteSupplier(supplier.id!);
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
        onPressed: () => _showSupplierDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showSupplierDialog(BuildContext context, [Supplier? supplier]) {
    nameController.text = supplier?.name ?? '';
    contactController.text = supplier?.contact ?? '';
    addressController.text = supplier?.address ?? '';

    Get.dialog(
      AlertDialog(
        title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Supplier Name *'),
              ),
              TextField(
                controller: contactController,
                decoration: InputDecoration(labelText: 'Contact'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter supplier name',
                  backgroundColor: Colors.white,
                );
                return;
              }

              final newSupplier = Supplier(
                id: supplier?.id,
                name: nameController.text,
                contact: contactController.text.isEmpty
                    ? null
                    : contactController.text,
                address: addressController.text.isEmpty
                    ? null
                    : addressController.text,
              );

              if (supplier == null) {
                supplierCtrl.addSupplier(newSupplier);
              } else {
                supplierCtrl.updateSupplier(newSupplier);
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
