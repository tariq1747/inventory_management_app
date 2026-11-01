import 'package:get/get.dart';
import 'package:inventory_management_app/controllers/category_controller.dart';
import 'package:inventory_management_app/controllers/customer_controller.dart';
import 'package:inventory_management_app/controllers/dashboard_controller.dart';
import 'package:inventory_management_app/controllers/expense_controller.dart';
import 'package:inventory_management_app/controllers/invoice_controller.dart';
import 'package:inventory_management_app/controllers/product_controller.dart';
import 'package:inventory_management_app/controllers/stock_movement_controller.dart';
import 'package:inventory_management_app/controllers/supplier_controller.dart';
import 'package:inventory_management_app/views/categories_view.dart';
import 'package:inventory_management_app/views/customers_view.dart';
import 'package:inventory_management_app/views/dashboard_view.dart';
import 'package:inventory_management_app/views/expenses_view.dart';
import 'package:inventory_management_app/views/invoices_view.dart';
import 'package:inventory_management_app/views/products_view.dart';
import 'package:inventory_management_app/views/reports_view.dart';
import 'package:inventory_management_app/views/stock_movements_view.dart';
import 'package:inventory_management_app/views/suppliers_view.dart';
import 'package:inventory_management_app/views/splash_screen.dart';

List<GetPage> getAppRoutes() {
  return [
    GetPage(name: splashRoute, page: () => const SplashScreen()),
    GetPage(
      name: dashboardRoute,
      page: () => DashboardView(),
      binding: BindingsBuilder(() {
        Get.put(ProductController());
        Get.put(InvoiceController());
        Get.put(DashboardController());
      }),
    ),

    GetPage(
      name: productsRoute,
      page: () => ProductsView(),
      binding: BindingsBuilder(() {
        Get.put(CategoryController());
        Get.put(ProductController());
        Get.put(SupplierController());
      }),
    ),
    GetPage(
      name: categoriesRoute,
      page: () => CategoriesView(),
      binding: BindingsBuilder(() {
        Get.put(CategoryController());
      }),
    ),
    GetPage(
      name: suppliersRoute,
      page: () => SuppliersView(),
      binding: BindingsBuilder(() {
        Get.put(SupplierController());
      }),
    ),
    GetPage(
      name: customersRoute,
      page: () => CustomersView(),
      binding: BindingsBuilder(() {
        Get.put(CustomerController());
      }),
    ),
    GetPage(
      name: invoicesRoute,
      page: () => InvoicesView(),
      binding: BindingsBuilder(() {
        Get.put(CustomerController());
        Get.put(InvoiceController());
      }),
    ),
    GetPage(
      name: expensesRoute,
      page: () => ExpensesView(),
      binding: BindingsBuilder(() {
        Get.put(ExpenseController());
      }),
    ),
    GetPage(
      name: stockMovementsRoute,
      page: () => StockMovementsView(),
      binding: BindingsBuilder(() {
        Get.put(StockMovementController());
      }),
    ),
    GetPage(
      name: '/Reports',
      page: () => ReportsView(),
      binding: BindingsBuilder(() {
        Get.put(InvoiceController());
      }),
    ),
  ];
}

String dashboardRoute = '/dashboard';
String splashRoute = '/';
String productsRoute = '/products';
String categoriesRoute = '/Categories';
String suppliersRoute = '/Suppliers';
String customersRoute = '/Customers';
String invoicesRoute = '/Invoices';
String expensesRoute = '/Expenses';
String stockMovementsRoute = '/Stock_Movements';
String reportsRoute = '/Reports';
