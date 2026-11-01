import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';

class CustomersView extends StatelessWidget {
  final CustomerController customerCtrl = Get.find<CustomerController>();
  final nameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customers')),
      body: Obx(() {
        if (customerCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: customerCtrl.loadCustomers,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: customerCtrl.customers.length,
            itemBuilder: (context, index) {
              final customer = customerCtrl.customers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text(customer.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${customer.contact ?? 'N/A'}'),
                      Text('Address: ${customer.address ?? 'N/A'}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text('Edit'), value: 'edit'),
                      PopupMenuItem(child: Text('Delete'), value: 'delete'),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showCustomerDialog(context, customer);
                      } else if (value == 'delete') {
                        customerCtrl.deleteCustomer(customer.id!);
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
        onPressed: () => _showCustomerDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCustomerDialog(BuildContext context, [Customer? customer]) {
    nameController.text = customer?.name ?? '';
    contactController.text = customer?.contact ?? '';
    addressController.text = customer?.address ?? '';

    Get.dialog(
      AlertDialog(
        title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Customer Name *'),
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
                  'Please enter customer name',
                  backgroundColor: Colors.white,
                );
                return;
              }

              final newCustomer = Customer(
                id: customer?.id,
                name: nameController.text,
                contact: contactController.text.isEmpty
                    ? null
                    : contactController.text,
                address: addressController.text.isEmpty
                    ? null
                    : addressController.text,
              );

              if (customer == null) {
                customerCtrl.addCustomer(newCustomer);
              } else {
                customerCtrl.updateCustomer(newCustomer);
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
