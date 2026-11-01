import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:inventory_management_app/rought.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/product_controller.dart';
import '../utils/themes.dart';
import 'products_view.dart';
import 'invoices_view.dart';

class DashboardView extends StatelessWidget {
  final DashboardController dashboardCtrl = Get.find<DashboardController>();
  final ProductController productCtrl = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                'Inventory Management',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: Icon(Icons.inventory),
              title: Text('Products'),
              onTap: () => Get.toNamed(productsRoute),
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
              onTap: () => Get.toNamed(categoriesRoute),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Suppliers'),
              onTap: () => Get.toNamed(suppliersRoute),
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Customers'),
              onTap: () => Get.toNamed(customersRoute),
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Invoices'),
              onTap: () => Get.toNamed(invoicesRoute),
            ),
            ListTile(
              leading: Icon(Icons.money_off),
              title: Text('Expenses'),
              onTap: () => Get.toNamed(expensesRoute),
            ),
            ListTile(
              leading: Icon(Icons.move_up),
              title: Text('Stock Movements'),
              onTap: () => Get.toNamed(stockMovementsRoute),
            ),
            ListTile(
              leading: Icon(Icons.bar_chart),
              title: Text('Reports'),
              onTap: () => Get.toNamed(reportsRoute),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (dashboardCtrl.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: dashboardCtrl.loadDashboardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildMetricCard(
                          'Total Stock Value',
                          '\$${dashboardCtrl.totalStockValue.value.toStringAsFixed(2)}',
                          Icons.inventory,
                          Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => _buildMetricCard(
                          'Today\'s Sales',
                          '\$${dashboardCtrl.todaySales.value.toStringAsFixed(2)}',
                          Icons.today,
                          Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _buildMetricCard(
                          'Monthly Sales',
                          '\$${dashboardCtrl.monthlySales.value.toStringAsFixed(2)}',
                          Icons.calendar_month,
                          Colors.orange,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Obx(
                        () => _buildMetricCard(
                          'Monthly Profit',
                          '\$${dashboardCtrl.monthlyProfit.value.toStringAsFixed(2)}',
                          Icons.trending_up,
                          Colors.purple,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Low Stock Alert
                Obx(() {
                  if (productCtrl.lowStockProducts.isEmpty) {
                    return SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Low Stock Alert',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),

                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${productCtrl.lowStockProducts.length} products are low on stock',
                              style: TextStyle(color: Colors.red.shade800),
                            ),
                            SizedBox(height: 8),
                            ...productCtrl.lowStockProducts
                                .take(3)
                                .map(
                                  (product) => Text(
                                    '${product.name}: ${product.quantity} remaining',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                            if (productCtrl.lowStockProducts.length > 3)
                              Text(
                                '...and ${productCtrl.lowStockProducts.length - 3} more',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                    ],
                  );
                }),
                SizedBox(height: 24),

                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Add Product',
                        Icons.add_box,
                        () => Get.toNamed(productsRoute),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        'New Invoice',
                        Icons.receipt_long,
                        () => Get.toNamed(invoicesRoute),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
