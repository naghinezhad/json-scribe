import 'package:flutter/material.dart';

class JsonToDartProvider with ChangeNotifier {
  String generatedCode = '';
  bool isCodeGenerated = false;

  void generateDartCodes(
    String dartCode,
  ) {
    generatedCode = dartCode;
    isCodeGenerated = true;
    notifyListeners();
  }
}
