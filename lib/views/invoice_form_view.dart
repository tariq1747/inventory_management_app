import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/invoice_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/customer_controller.dart';
import '../models/product.dart';

class InvoiceFormView extends StatefulWidget {
  @override
  State<InvoiceFormView> createState() => _InvoiceFormViewState();
}

class _InvoiceFormViewState extends State<InvoiceFormView> {
  final InvoiceController invoiceCtrl = Get.find<InvoiceController>();
  final ProductController productCtrl = Get.find<ProductController>();
  final CustomerController customerCtrl = Get.find<CustomerController>();

  int? selectedCustomerId;
  final discountController = TextEditingController();
  final quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    customerCtrl.loadCustomers();
  }

  @override
  void dispose() {
    invoiceCtrl.clearInvoice();
    discountController.dispose();
    quantityController.dispose();
    productCtrl.selecetdProduct.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invoice'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: invoiceCtrl.clearInvoice,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            // Customer selection
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    'Select Customer',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Customer',
                        border: OutlineInputBorder(),
                        hintText: 'Select a customer (Optional)',
                      ),
                      value: selectedCustomerId,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Walk-in Customer'),
                        ),
                        ...customerCtrl.customers.map((customer) {
                          return DropdownMenuItem(
                            value: customer.id,
                            child: Text(customer.name),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() => selectedCustomerId = value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Product selection
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Text(
                    'Add Products',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Product>(
                          decoration: InputDecoration(
                            labelText: 'Select Product',
                            border: OutlineInputBorder(),
                          ),
                          items: productCtrl.products.map((product) {
                            return DropdownMenuItem(
                              value: product,
                              child: Text(
                                '${product.name} (\$${product.sellingPrice})',
                              ),
                            );
                          }).toList(),
                          onChanged: (product) {
                            if (product != null) {
                              productCtrl.selecetdProduct.value = product;
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: quantityController,
                          decoration: InputDecoration(
                            labelText: 'Qty',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  Obx(() {
                    return ElevatedButton(
                      onPressed: productCtrl.selecetdProduct.value == null
                          ? null
                          : () => _addProductToInvoice(
                              productCtrl.selecetdProduct.value!,
                            ),
                      child: Text('Add'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Invoice items
            Obx(() {
              if (invoiceCtrl.invoiceItems.isEmpty) {
                return Center(child: Text('No products added yet'));
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: invoiceCtrl.invoiceItems.length,
                itemBuilder: (context, index) {
                  final item = invoiceCtrl.invoiceItems[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(item.productName ?? 'Unknown Product'),
                      subtitle: Text(
                        'Unit Price: \$${item.unitPrice.toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              invoiceCtrl.updateItemQuantity(
                                index,
                                item.quantity - 1,
                              );
                              setState(() {});
                            },
                          ),
                          Text('${item.quantity}'),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              invoiceCtrl.updateItemQuantity(
                                index,
                                item.quantity + 1,
                              );
                              setState(() {});
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                invoiceCtrl.removeProductFromInvoice(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            // Totals and actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Obx(
                () => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: discountController,
                            decoration: InputDecoration(
                              labelText: 'Discount (\$)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              final discount = double.tryParse(value) ?? 0;
                              invoiceCtrl.setDiscount(discount);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Subtotal:'),
                        Text('\$${invoiceCtrl.subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discount:'),
                        Text('-\$${invoiceCtrl.discount.toStringAsFixed(2)}'),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '\$${invoiceCtrl.grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: invoiceCtrl.invoiceItems.isEmpty
                          ? null
                          : _createInvoice,
                      child: Text('Create Invoice'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addProductToInvoice(Product product) {
    final quantity = int.tryParse(quantityController.text) ?? 1;
    if (quantity <= 0) {
      Get.snackbar(
        'Error',
        'Quantity must be greater than 0',
        backgroundColor: Colors.white,
      );
      return;
    }

    invoiceCtrl.addProductToInvoice(product, quantity);
    setState(() {});
    quantityController.text = '1';
  }

  void _createInvoice() {
    invoiceCtrl.createInvoice(customerId: selectedCustomerId);
    Get.back();
  }
}
