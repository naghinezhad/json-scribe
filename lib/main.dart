import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

void main() {
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const JsonToDartConverter(),
    );
  }
}

class JsonToDartConverter extends StatefulWidget {
  const JsonToDartConverter({super.key});

  @override
  State<JsonToDartConverter> createState() => _JsonToDartConverterState();
}

class _JsonToDartConverterState extends State<JsonToDartConverter> {
  final _jsonController = TextEditingController();
  final _classNameController = TextEditingController();
  String _generatedCode = '';

  void _generateDartCode() {
    if (_jsonController.text.isEmpty || _classNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً JSON و نام کلاس را وارد کنید.')),
      );
      return;
    }

    try {
      final jsonData = json.decode(_jsonController.text);
      final className = _classNameController.text;
      final convertedData = _convertDynamic(jsonData);
      final dartCode = _convertJsonToDart(convertedData, className);
      setState(() {
        _generatedCode = dartCode;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در تجزیه JSON: $e')),
      );
    }
  }

  dynamic _convertDynamic(dynamic item) {
    if (item is Map) {
      return _convertDynamicMap(item);
    } else if (item is List) {
      return _convertDynamicList(item);
    } else {
      return item;
    }
  }

  Map<String, dynamic> _convertDynamicMap(Map<dynamic, dynamic> map) {
    return map
        .map((key, value) => MapEntry(key.toString(), _convertDynamic(value)));
  }

  List<dynamic> _convertDynamicList(List<dynamic> list) {
    return list.map((item) => _convertDynamic(item)).toList();
  }

  String _convertJsonToDart(dynamic jsonData, String className) {
    final buffer = StringBuffer();

    if (jsonData is Map<String, dynamic>) {
      buffer.writeln(_convertMapToDartClass(jsonData, className));
    } else if (jsonData is List) {
      buffer.writeln(_convertListToDartClass(jsonData, className));
    } else {
      throw Exception('داده JSON باید یک شیء یا آرایه باشد.');
    }

    return buffer.toString();
  }

  String _convertMapToDartClass(Map<String, dynamic> map, String className) {
    final buffer = StringBuffer();
    buffer.writeln('class $className {');

    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final type = _getTypeName(value, key);

      buffer.writeln('  $type? $key;');
    }

    buffer.writeln('\n  $className({');
    for (var key in map.keys) {
      buffer.writeln('    this.$key,');
    }
    buffer.writeln('  });');

    buffer.writeln(
        '\n  factory $className.fromJson(Map<String, dynamic> json) => $className(');
    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is Map) {
        buffer.writeln(
            '    $key: json["$key"] != null ? ${_capitalizeFirstLetter(key)}.fromJson(json["$key"]) : null,');
      } else if (value is List && value.isNotEmpty && value[0] is Map) {
        buffer.writeln(
            '    $key: json["$key"] != null ? List<${_getTypeName(value[0], _singularize(key))}>.from(json["$key"].map((x) => ${_getTypeName(value[0], _singularize(key))}.fromJson(x))) : null,');
      } else {
        buffer.writeln('    $key: json["$key"],');
      }
    }
    buffer.writeln('  );');

    buffer.writeln('\n  Map<String, dynamic> toJson() => {');
    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is Map) {
        buffer.writeln('    "$key": $key?.toJson(),');
      } else if (value is List && value.isNotEmpty && value[0] is Map) {
        buffer.writeln(
            '    "$key": $key != null ? List<dynamic>.from($key!.map((x) => x.toJson())) : null,');
      } else {
        buffer.writeln('    "$key": $key,');
      }
    }
    buffer.writeln('  };');

    buffer.writeln('}');

    for (var entry in map.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        buffer.writeln(
            '\n${_convertMapToDartClass(value, _capitalizeFirstLetter(entry.key))}');
      } else if (value is List &&
          value.isNotEmpty &&
          value[0] is Map<String, dynamic>) {
        buffer.writeln(
            '\n${_convertMapToDartClass(value[0], _capitalizeFirstLetter(_singularize(entry.key)))}');
      }
    }

    return buffer.toString();
  }

  String _convertListToDartClass(List list, String className) {
    if (list.isEmpty) {
      return 'List<dynamic>';
    }

    final firstItem = list.first;
    if (firstItem is Map<String, dynamic>) {
      return _convertMapToDartClass(firstItem, _singularize(className));
    } else {
      return 'List<${_getTypeName(firstItem, className)}>';
    }
  }

  String _getTypeName(dynamic value, String key) {
    if (value is String) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) {
      if (value.isEmpty) return 'List<dynamic>';
      return 'List<${_getTypeName(value.first, _singularize(key))}>';
    }
    if (value is Map) return _capitalizeFirstLetter(key);
    return 'dynamic';
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _singularize(String text) {
    if (text.endsWith('ies')) {
      return '${text.substring(0, text.length - 3)}y';
    }
    if (text.endsWith('s')) {
      return text.substring(0, text.length - 1);
    }
    return text;
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('کد در کلیپ‌بورد کپی شد.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تبدیل کننده JSON به Dart'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(labelText: 'نام کلاس'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jsonController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'JSON ورودی',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateDartCode,
              child: const Text('تولید کد Dart'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_generatedCode),
              ),
            ),
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: const Text('کپی کد'),
            ),
          ],
        ),
      ),
    );
  }
}
