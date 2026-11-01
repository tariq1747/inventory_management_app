import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/controllers/product_controller.dart';
import '../controllers/invoice_controller.dart';
import '../models/invoice.dart';
import '../services/pdf_service.dart';
import 'invoice_form_view.dart';

class InvoicesView extends StatelessWidget {
  final InvoiceController invoiceCtrl = Get.find<InvoiceController>();
  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Invoices')),
      body: Obx(() {
        if (invoiceCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: invoiceCtrl.loadInvoices,
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 100),
            itemCount: invoiceCtrl.invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoiceCtrl.invoices[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  title: Text('Invoice ${invoice.invoiceNumber}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Customer: ${invoice.customerName ?? 'Walk-in'}'),
                      Text('Total: \$${invoice.grandTotal.toStringAsFixed(2)}'),
                      Text('Date: ${invoice.createdAt?.split('T')[0] ?? ''}'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(child: Text('View Details'), value: 'view'),
                      PopupMenuItem(child: Text('Print PDF'), value: 'print'),
                      PopupMenuItem(child: Text('Delete'), value: 'delete'),
                    ],
                    onSelected: (value) => _handleMenuAction(value, invoice),
                  ),
                  onTap: () => _viewInvoiceDetails(invoice),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => InvoiceFormView()),
        child: Icon(Icons.add),
      ),
    );
  }

  void _handleMenuAction(String action, Invoice invoice) {
    switch (action) {
      case 'view':
        _viewInvoiceDetails(invoice);
        break;
      case 'print':
        _printInvoice(invoice);
        break;
      case 'delete':
        _showDeleteConfirmation(invoice);
        break;
    }
  }

  void _viewInvoiceDetails(Invoice invoice) async {
    final fullInvoice = await invoiceCtrl.getInvoiceById(invoice.id!);
    if (fullInvoice != null) {
      Get.dialog(
        AlertDialog(
          title: Text('Invoice ${invoice.invoiceNumber}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Customer: ${fullInvoice.customerName ?? 'Walk-in'}'),
                Text('Date: ${fullInvoice.createdAt?.split('T')[0] ?? ''}'),
                Divider(),
                ...?fullInvoice.items?.map(
                  (item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(item.productName ?? 'Unknown'),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('= \$${item.total.toStringAsFixed(2)}'),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(),
                Text('Subtotal: \$${fullInvoice.subtotal.toStringAsFixed(2)}'),
                if (fullInvoice.discount > 0)
                  Text(
                    'Discount: -\$${fullInvoice.discount.toStringAsFixed(2)}',
                  ),
                Text(
                  'Total: \$${fullInvoice.grandTotal.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text('Close')),
            TextButton(
              onPressed: () => _printInvoice(fullInvoice),
              child: Text('Print'),
            ),
          ],
        ),
      );
    }
  }

  void _printInvoice(Invoice invoice) async {
    final fullInvoice = await invoiceCtrl.getInvoiceById(invoice.id!);
    if (fullInvoice != null && fullInvoice.items != null) {
      await PdfService.generateInvoicePdf(fullInvoice, fullInvoice.items!);
    }
  }

  void _showDeleteConfirmation(Invoice invoice) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Invoice'),
        content: Text(
          'Are you sure you want to delete invoice ${invoice.invoiceNumber}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              invoiceCtrl.deleteInvoice(invoice.id!);
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
