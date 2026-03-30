import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/vault_item.dart';

class VaultMemoryRepository {
  static const String _storageKey = 'vault_items';

  Future<List<VaultItem>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded
        .map((item) => VaultItem.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> addItem(VaultItem item) async {
    final items = await getItems();
    items.add(item);
    await saveAllItems(items);
  }

  Future<void> updateItem(VaultItem updatedItem) async {
    final items = await getItems();

    final updatedList = items.map((item) {
      if (item.id == updatedItem.id) {
        return updatedItem;
      }
      return item;
    }).toList();

    await saveAllItems(updatedList);
  }

  Future<void> deleteItem(String id) async {
    final items = await getItems();
    items.removeWhere((item) => item.id == id);
    await saveAllItems(items);
  }

  Future<void> saveAllItems(List<VaultItem> items) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      items.map((item) => item.toMap()).toList(),
    );

    await prefs.setString(_storageKey, encoded);
  }
}