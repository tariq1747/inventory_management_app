import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventory_management_app/rought.dart';
import 'utils/themes.dart';
import 'views/dashboard_view.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('Tariq APP');
    return GetMaterialApp(
      title: 'Inventory Management App',
      theme: AppThemes.lightTheme,
      getPages: getAppRoutes(),
      initialRoute: splashRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
