import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:get/get.dart';
import 'package:layout/layout.dart';

import '../service/api_service.dart';

class AppWidget extends StatelessWidget {
  final String appName;
  const AppWidget({super.key, required this.appName});

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: GetMaterialApp(
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationService.navigatorKey,
        home: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: appName,
          routeInformationParser: Modular.routeInformationParser,
          routerDelegate: Modular.routerDelegate,
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
        ),
      ),
    );
  }
}
