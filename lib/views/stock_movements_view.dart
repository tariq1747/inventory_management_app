import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/models/product.dart';
import '../controllers/stock_movement_controller.dart';
import '../controllers/product_controller.dart';

class StockMovementsView extends StatelessWidget {
  final StockMovementController stockCtrl = Get.find<StockMovementController>();
  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Movements'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: stockCtrl.loadStockMovements,
          ),
        ],
      ),
      body: Obx(() {
        if (stockCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (stockCtrl.stockMovements.isEmpty) {
          return Center(child: Text('No stock movements yet'));
        }

        return RefreshIndicator(
          onRefresh: stockCtrl.loadStockMovements,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: stockCtrl.stockMovements.length,
            itemBuilder: (context, index) {
              final movement = stockCtrl.stockMovements[index];
              final isStockIn = movement.type == 'in';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    isStockIn ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isStockIn ? Colors.green : Colors.red,
                  ),
                  title: Text(movement.productName ?? 'Unknown Product'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isStockIn ? 'Stock In' : 'Stock Out'}: ${movement.quantity} units',
                      ),
                      Text('Reason: ${movement.reason ?? 'N/A'}'),
                      Text(
                        'Date: ${movement.createdAt?.split('T')[0] ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    isStockIn
                        ? '+${movement.quantity}'
                        : '-${movement.quantity}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isStockIn ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecordMovementDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showRecordMovementDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final reasonController = TextEditingController();
    var selectedProduct = Rxn<Product>();
    var movementType = 'in'.obs;

    Get.dialog(
      AlertDialog(
        title: Text('Record Stock Movement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => DropdownButtonFormField<Product>(
                  decoration: InputDecoration(labelText: 'Product *'),
                  items: productCtrl.products.map((product) {
                    return DropdownMenuItem(
                      value: product,
                      child: Text(product.name),
                    );
                  }).toList(),
                  onChanged: (value) => selectedProduct.value = value,
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => Column(
                  children: [
                    RadioListTile(
                      title: Text('Stock In'),
                      value: 'in',
                      groupValue: movementType.value,
                      onChanged: (value) => movementType.value = value ?? 'in',
                    ),
                    RadioListTile(
                      title: Text('Stock Out'),
                      value: 'out',
                      groupValue: movementType.value,
                      onChanged: (value) => movementType.value = value ?? 'out',
                    ),
                  ],
                ),
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity *'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(labelText: 'Reason'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              if (selectedProduct.value == null ||
                  quantityController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please fill required fields',
                  backgroundColor: Colors.white,
                );
                return;
              }

              final quantity = int.tryParse(quantityController.text) ?? 0;
              if (movementType.value == 'in') {
                stockCtrl.recordStockIn(
                  selectedProduct.value!,
                  quantity,
                  reasonController.text,
                );
              } else {
                if (quantity > selectedProduct.value!.quantity) {
                  Future.delayed(Duration(milliseconds: 500), () {
                    Get.snackbar(
                      'Error',
                      'Insufficient stock for this operation',
                      backgroundColor: Colors.white,
                    );
                  });
                } else {
                  stockCtrl.recordStockOut(
                    selectedProduct.value!,
                    quantity,
                    reasonController.text,
                  );
                }
              }
              Get.back();
            },
            child: Text('Record'),
          ),
        ],
      ),
    );
  }
}
