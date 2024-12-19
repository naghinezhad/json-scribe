import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:json_scribe/apps/theme_app.dart';
import 'package:json_scribe/services/theme_service/theme_service.dart';
import 'package:json_scribe/pages/json_to_dart_page/json_to_dart_page.dart';
import 'package:json_scribe/services/providers_service/providers_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: getProviders(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: "json scribe",
            debugShowCheckedModeBanner: false,
            scrollBehavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
                PointerDeviceKind.stylus,
                PointerDeviceKind.unknown
              },
            ),
            theme: Styles.themeData(themeProvider.darkTheme),
            home: const JsonToDartPage(),
          );
        },
      ),
    );
  }
}
