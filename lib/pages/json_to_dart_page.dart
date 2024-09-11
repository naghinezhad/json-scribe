import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:json_scribe/services/theme_service.dart';
import 'dart:convert';

class JsonToDartPage extends StatefulWidget {
  const JsonToDartPage({super.key});

  @override
  State<JsonToDartPage> createState() => _JsonToDartPageState();
}

class _JsonToDartPageState extends State<JsonToDartPage> {
  final TextEditingController _jsonController = TextEditingController();
  final TextEditingController _classNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _generatedCode = '';
  bool _isCodeGenerated = false;

  @override
  void dispose() {
    _jsonController.dispose();
    _classNameController.dispose();
    super.dispose();
  }

  void _generateDartCode() {
    if (_formKey.currentState!.validate()) {
      try {
        final jsonData = json.decode(_jsonController.text);
        final className = _classNameController.text;
        final convertedData = _convertDynamic(jsonData);
        final dartCode = _convertJsonToDart(convertedData, className);
        setState(() {
          _generatedCode = dartCode;
          _isCodeGenerated = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing JSON: $e')),
        );
      }
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
      throw Exception('JSON data must be an object or an array.');
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
      final camelCaseKey = _toCamelCase(key);

      buffer.writeln('  $type? $camelCaseKey;');
    }

    buffer.writeln('\n  $className({');
    for (var key in map.keys) {
      final camelCaseKey = _toCamelCase(key);
      buffer.writeln('    this.$camelCaseKey,');
    }
    buffer.writeln('  });');

    buffer.writeln(
        '\n  factory $className.fromJson(Map<String, dynamic> json) => $className(');
    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final camelCaseKey = _toCamelCase(key);
      if (value is Map) {
        buffer.writeln(
            '    $camelCaseKey: json["$key"] != null ? ${_capitalizeFirstLetter(camelCaseKey)}.fromJson(json["$key"]) : null,');
      } else if (value is List && value.isNotEmpty && value[0] is Map) {
        buffer.writeln(
            '    $camelCaseKey: json["$key"] != null ? List<${_getTypeName(value[0], _singularize(camelCaseKey))}>.from(json["$key"].map((x) => ${_getTypeName(value[0], _singularize(camelCaseKey))}.fromJson(x))) : null,');
      } else {
        buffer.writeln('    $camelCaseKey: json["$key"],');
      }
    }
    buffer.writeln('  );');

    buffer.writeln('\n  Map<String, dynamic> toJson() => {');
    for (var entry in map.entries) {
      final key = entry.key;
      final value = entry.value;
      final camelCaseKey = _toCamelCase(key);
      if (value is Map) {
        buffer.writeln('    "$key": $camelCaseKey?.toJson(),');
      } else if (value is List && value.isNotEmpty && value[0] is Map) {
        buffer.writeln(
            '    "$key": $camelCaseKey != null ? List<dynamic>.from($camelCaseKey!.map((x) => x.toJson())) : null,');
      } else {
        buffer.writeln('    "$key": $camelCaseKey,');
      }
    }
    buffer.writeln('  };');

    buffer.writeln('}');

    for (var entry in map.entries) {
      final value = entry.value;
      if (value is Map<String, dynamic>) {
        buffer.writeln(
            '\n${_convertMapToDartClass(value, _capitalizeFirstLetter(_toCamelCase(entry.key)))}');
      } else if (value is List &&
          value.isNotEmpty &&
          value[0] is Map<String, dynamic>) {
        buffer.writeln(
            '\n${_convertMapToDartClass(value[0], _capitalizeFirstLetter(_singularize(_toCamelCase(entry.key))))}');
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
    if (value is Map) return _capitalizeFirstLetter(_toCamelCase(key));
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

  String _toCamelCase(String text) {
    final words = text.split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return '';
    return words[0].toLowerCase() +
        words.sublist(1).map(_capitalizeFirstLetter).join('');
  }

  void _copyToClipboard() {
    if (_isCodeGenerated) {
      Clipboard.setData(ClipboardData(text: _generatedCode));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please generate Dart code first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON to Dart Converter'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: IconButton(
              icon: Icon(
                themeProvider.darkTheme
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
              ),
              onPressed: () {
                themeProvider.darkTheme = !themeProvider.darkTheme;
              },
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: _buildInputColumn(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: _buildOutputColumn(),
                    ),
                  ),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildInputColumn(),
                    _buildOutputColumn(),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInputColumn() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _classNameController,
            decoration: const InputDecoration(
              labelText: 'Class Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a class name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _jsonController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Input JSON',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter JSON data';
              }
              try {
                json.decode(value);
              } catch (e) {
                return 'Invalid JSON format';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _generateDartCode,
            child: const Text('Generate Dart Code'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isCodeGenerated ? _copyToClipboard : null,
            child: const Text('Copy Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputColumn() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              color:
                  themeProvider.darkTheme ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.darkTheme
                      ? Colors.black.withOpacity(0.5)
                      : Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text(
                _generatedCode,
                style: TextStyle(
                  color: themeProvider.darkTheme ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
