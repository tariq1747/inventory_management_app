import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'product_form_view.dart';

class ProductsView extends StatelessWidget {
  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      initState: (state) async {
        await productCtrl.loadProducts();
      },
      builder: (_) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Products'),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () => _showSearchDialog(context),
              ),
            ],
          ),
          body: Obx(() {
            if (productCtrl.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: productCtrl.loadProducts,
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: productCtrl.products.length,
                itemBuilder: (context, index) {
                  final product = productCtrl.products[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SKU: ${product.sku ?? 'N/A'} | Qty: ${product.quantity}',
                          ),
                          Text(
                            'Price: \$${product.sellingPrice.toStringAsFixed(2)}',
                          ),
                          if (product.isLowStock)
                            Text(
                              'LOW STOCK',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(child: Text('Edit'), value: 'edit'),
                          PopupMenuItem(
                            child: Text('Update Stock'),
                            value: 'stock',
                          ),
                          PopupMenuItem(child: Text('Delete'), value: 'delete'),
                        ],
                        onSelected: (value) =>
                            _handleMenuAction(value, product),
                      ),
                      onTap: () =>
                          Get.to(() => ProductFormView(product: product)),
                    ),
                  );
                },
              ),
            );
          }),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.to(() => ProductFormView()),
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Search Products'),
        content: TextField(
          onChanged: (value) => productCtrl.searchProducts(value),
          decoration: InputDecoration(
            hintText: 'Enter product name, SKU, or barcode',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              productCtrl.searchProducts('');
              Navigator.of(context).pop();
            },
            child: Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action, Product product) {
    switch (action) {
      case 'edit':
        Get.to(() => ProductFormView(product: product));
        break;
      case 'stock':
        _showUpdateStockDialog(product);
        break;
      case 'delete':
        _showDeleteConfirmation(product);
        break;
    }
  }

  void _showUpdateStockDialog(Product product) {
    final quantityController = TextEditingController(
      text: product.quantity.toString(),
    );
    final reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: 'New Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(labelText: 'Reason'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              final newQuantity =
                  int.tryParse(quantityController.text) ?? product.quantity;
              final reason = reasonController.text.isEmpty
                  ? 'Manual update'
                  : reasonController.text;
              productCtrl.updateStock(product.id!, newQuantity, reason);
              Get.back();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Product product) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              productCtrl.deleteProduct(product.id!);
              Get.back();
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
