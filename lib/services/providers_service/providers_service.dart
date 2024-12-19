import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:json_scribe/services/theme_service/theme_service.dart';
import 'package:json_scribe/services/json_to_dart_service/json_to_dart_provider.dart';

List<SingleChildWidget> getProviders() {
  return [
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
    ),
    ChangeNotifierProvider(
      create: (context) => JsonToDartProvider(),
    ),
  ];
}
