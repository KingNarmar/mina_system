import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'demo_storage_keys.dart';

class DemoLocalStorageService {
  const DemoLocalStorageService();

  Future<bool> readBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(key) ?? defaultValue;
  }

  Future<void> writeBool({required String key, required bool value}) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(key, value);
  }

  Future<Map<String, dynamic>?> readJsonObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(key);

    if (rawValue == null || rawValue.trim().isEmpty) {
      return null;
    }

    final decodedValue = jsonDecode(rawValue);

    if (decodedValue is! Map<String, dynamic>) {
      throw FormatException(
        'Expected a JSON object for demo storage key "$key".',
      );
    }

    return decodedValue;
  }

  Future<void> writeJsonObject({
    required String key,
    required Map<String, dynamic> value,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(value));
  }

  Future<List<Map<String, dynamic>>> readJsonList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(key);

    if (rawValue == null || rawValue.trim().isEmpty) {
      return const [];
    }

    final decodedValue = jsonDecode(rawValue);

    if (decodedValue is! List) {
      throw FormatException(
        'Expected a JSON list for demo storage key "$key".',
      );
    }

    return decodedValue
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw FormatException(
              'Expected every item in "$key" to be a JSON object.',
            );
          }

          return item;
        })
        .toList(growable: false);
  }

  Future<void> writeJsonList({
    required String key,
    required List<Map<String, dynamic>> value,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(key, jsonEncode(value));
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(key);
  }

  Future<void> clearDemoData() async {
    final prefs = await SharedPreferences.getInstance();

    for (final key in DemoStorageKeys.allKeys) {
      await prefs.remove(key);
    }
  }

  Future<bool> get isInitialized {
    return readBool(DemoStorageKeys.isInitialized);
  }

  Future<void> markInitialized() {
    return writeBool(key: DemoStorageKeys.isInitialized, value: true);
  }
}
