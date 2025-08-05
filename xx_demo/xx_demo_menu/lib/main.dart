import 'package:flutter/material.dart';
import 'package:xx_demo_menu/main_scroll_view.dart';
import 'package:xx_demo_menu/main_simple.dart';

import 'package:xx_demo_menu/menu_demo.dart';

// class MacNoProxyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     var client = super.createHttpClient(context);
//     client.findProxy = (uri) => 'DIRECT';
//     client.connectionTimeout = Duration(seconds: 10);
//     // 忽略证书错误（仅用于开发）
//     client.badCertificateCallback =
//         (X509Certificate cert, String host, int port) => true;
//     return client;
//   }
// }

void main() {
  // HttpOverrides.global = MacNoProxyHttpOverrides();
  if (bool.fromEnvironment('menu', defaultValue: false)) {
    runApp(const MenuDemo());
  } else if (bool.fromEnvironment('scroll', defaultValue: true)) {
    runApp(DemoScrollView());
  } else {
    runApp(DemoSimple());
  }
}
