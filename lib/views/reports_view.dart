import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/invoice_controller.dart';
import '../controllers/product_controller.dart';
import '../repositories/expense_repository.dart';

class ReportsView extends StatefulWidget {
  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final InvoiceController invoiceCtrl = Get.find<InvoiceController>();
  final ProductController productCtrl = Get.find<ProductController>();
  final ExpenseRepository expenseRepo = ExpenseRepository();

  double monthlySales = 0;
  double monthlyExpenses = 0;
  double monthlyProfit = 0;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<double> _calculateMonthlyCOGS() async {
    // Get all invoices for the current month
    final monthlyInvoices = await invoiceCtrl.getMonthlyInvoices();
    double totalCOGS = 0.0;

    for (var invoice in monthlyInvoices) {
      // Calculate COGS for each invoice item (cost price × quantity)
      final items = await invoiceCtrl.getInvoiceItems(invoice.id!);
      for (var item in items) {
        totalCOGS += (item.costPrice ?? 0.0) * item.quantity;
      }
    }

    return totalCOGS;
  }

  Future<void> _loadReportData() async {
    monthlySales = await invoiceCtrl.getTotalSales(period: 'month');
    final monthlyExpenses = await expenseRepo.getTotalExpenses(period: 'month');
    final monthlyCOGS = await _calculateMonthlyCOGS();
    monthlyProfit = monthlySales - monthlyExpenses - monthlyCOGS;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports & Analytics')),
      body: RefreshIndicator(
        onRefresh: _loadReportData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profit & Loss Summary
              Text(
                'Profit & Loss (This Month)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Total Sales',
                        monthlySales,
                        Colors.green,
                      ),
                      _buildSummaryRow(
                        'Total Expenses',
                        monthlyExpenses,
                        Colors.red,
                      ),
                      Divider(),
                      _buildSummaryRow(
                        'Net Profit/Loss',
                        monthlyProfit,
                        monthlyProfit >= 0 ? Colors.green : Colors.red,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Sales Chart
              Text(
                'Monthly Sales Trend',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // SizedBox(height: 16),
              // Container(
              //   height: 200,
              //   child: LineChart(
              //     LineChartData(
              //       gridData: FlGridData(show: false),
              //       titlesData: FlTitlesData(show: false),
              //       borderData: FlBorderData(show: false),
              //       lineBarsData: [
              //         LineChartBarData(
              //           spots: [
              //             FlSpot(0, 1200),
              //             FlSpot(1, 1500),
              //             FlSpot(2, 1800),
              //             FlSpot(3, monthlySales), // Current month
              //           ],
              //           isCurved: true,
              //           color: Colors.blue,
              //           barWidth: 4,
              //           belowBarData: BarAreaData(show: false),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SizedBox(height: 24),

              // // Product Performance
              // Text(
              //   'Top Selling Products',
              //   style: Theme.of(context).textTheme.titleLarge,
              // ),
              // SizedBox(height: 16),
              // Container(
              //   height: 200,
              //   child: BarChart(
              //     BarChartData(
              //       alignment: BarChartAlignment.spaceAround,
              //       maxY: 100,
              //       barTouchData: BarTouchData(enabled: false),
              //       titlesData: FlTitlesData(
              //         show: true,
              //         bottomTitles: AxisTitles(
              //           sideTitles: SideTitles(
              //             showTitles: true,
              //             getTitlesWidget: (value, meta) {
              //               const titles = [
              //                 'Prod A',
              //                 'Prod B',
              //                 'Prod C',
              //                 'Prod D',
              //               ];
              //               return Text(titles[value.toInt()]);
              //             },
              //           ),
              //         ),
              //         leftTitles: AxisTitles(
              //           sideTitles: SideTitles(showTitles: false),
              //         ),
              //         topTitles: AxisTitles(
              //           sideTitles: SideTitles(showTitles: false),
              //         ),
              //         rightTitles: AxisTitles(
              //           sideTitles: SideTitles(showTitles: false),
              //         ),
              //       ),
              //       gridData: FlGridData(show: false),
              //       borderData: FlBorderData(show: false),
              //       barGroups: [
              //         BarChartGroupData(
              //           x: 0,
              //           barRods: [BarChartRodData(toY: 80, color: Colors.blue)],
              //         ),
              //         BarChartGroupData(
              //           x: 1,
              //           barRods: [BarChartRodData(toY: 65, color: Colors.blue)],
              //         ),
              //         BarChartGroupData(
              //           x: 2,
              //           barRods: [BarChartRodData(toY: 50, color: Colors.blue)],
              //         ),
              //         BarChartGroupData(
              //           x: 3,
              //           barRods: [BarChartRodData(toY: 35, color: Colors.blue)],
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // SizedBox(height: 24),

              // Low Stock Products
              Text(
                'Low Stock Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 16),
              Obx(() {
                if (productCtrl.lowStockProducts.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('All products are well stocked!'),
                    ),
                  );
                }

                return Column(
                  children: productCtrl.lowStockProducts.map((product) {
                    return Card(
                      child: ListTile(
                        title: Text(product.name),
                        subtitle: Text('Current stock: ${product.quantity}'),
                        trailing: Text(
                          'Threshold: ${product.lowStockThreshold}',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    Color color, {
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
