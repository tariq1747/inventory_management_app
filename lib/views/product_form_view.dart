import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/supplier_controller.dart';
import '../models/product.dart';
import '../services/barcode_service.dart';

class ProductFormView extends StatefulWidget {
  final Product? product;

  ProductFormView({this.product});

  @override
  _ProductFormViewState createState() => _ProductFormViewState();
}

class _ProductFormViewState extends State<ProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final ProductController productCtrl = Get.find<ProductController>();
  final CategoryController categoryCtrl = Get.find<CategoryController>();
  final SupplierController supplierCtrl = Get.find<SupplierController>();

  late TextEditingController nameController;
  late TextEditingController skuController;
  late TextEditingController barcodeController;
  late TextEditingController purchasePriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController quantityController;
  late TextEditingController lowStockThresholdController;
  int? selectedCategoryId;
  int? selectedSupplierId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product?.name ?? '');
    skuController = TextEditingController(text: widget.product?.sku ?? '');
    barcodeController = TextEditingController(
      text: widget.product?.barcode ?? '',
    );
    purchasePriceController = TextEditingController(
      text: widget.product?.purchasePrice.toString() ?? '',
    );
    sellingPriceController = TextEditingController(
      text: widget.product?.sellingPrice.toString() ?? '',
    );
    quantityController = TextEditingController(
      text: widget.product?.quantity.toString() ?? '0',
    );
    lowStockThresholdController = TextEditingController(
      text: widget.product?.lowStockThreshold.toString() ?? '10',
    );
    selectedCategoryId = widget.product?.categoryId;
    selectedSupplierId = widget.product?.supplierId;
  }

  @override
  void dispose() {
    nameController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    purchasePriceController.dispose();
    sellingPriceController.dispose();
    quantityController.dispose();
    lowStockThresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          if (widget.product != null)
            IconButton(icon: Icon(Icons.delete), onPressed: _deleteProduct),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name *'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: skuController,
                decoration: InputDecoration(labelText: 'SKU'),
              ),
              TextFormField(
                controller: barcodeController,
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: _scanBarcode,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Category'),
                  value: selectedCategoryId,
                  items: categoryCtrl.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedCategoryId = value),
                ),
              ),
              SizedBox(height: 16),
              Obx(
                () => DropdownButtonFormField<int>(
                  decoration: InputDecoration(labelText: 'Supplier'),
                  value: selectedSupplierId,
                  items: supplierCtrl.suppliers.map((supplier) {
                    return DropdownMenuItem(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedSupplierId = value),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: purchasePriceController,
                decoration: InputDecoration(labelText: 'Purchase Price *'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              TextFormField(
                controller: sellingPriceController,
                decoration: InputDecoration(labelText: 'Selling Price *'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              if (widget.product == null)
                TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'Quantity *'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              TextFormField(
                controller: lowStockThresholdController,
                decoration: InputDecoration(labelText: 'Low Stock Threshold'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(
                  widget.product == null ? 'Add Product' : 'Update Product',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    final barcode = await BarcodeService.scanBarcode(context);
    if (barcode != null) {
      barcodeController.text = barcode;
    }
  }

  void _saveProduct() {
    if (double.parse(purchasePriceController.text) >
        double.parse(sellingPriceController.text)) {
      Get.snackbar(
        'Error',
        'Selling price must be greater than purchase price',
        backgroundColor: Colors.white,
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final product = Product(
        id: widget.product?.id,
        name: nameController.text,
        sku: skuController.text.isEmpty ? null : skuController.text,
        barcode: barcodeController.text.isEmpty ? null : barcodeController.text,
        purchasePrice: double.parse(purchasePriceController.text),
        sellingPrice: double.parse(sellingPriceController.text),
        quantity: int.parse(quantityController.text),
        lowStockThreshold: int.parse(lowStockThresholdController.text),
      );

      if (widget.product == null) {
        productCtrl.addProduct(product);
      } else {
        productCtrl.updateProduct(product);
      }

      Get.back();
    }
  }

  void _deleteProduct() {
    if (widget.product != null) {
      Get.dialog(
        AlertDialog(
          title: Text('Delete Product'),
          content: Text(
            'Are you sure you want to delete ${widget.product!.name}?',
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                productCtrl.deleteProduct(widget.product!.id!);
                Get.back();
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
}
