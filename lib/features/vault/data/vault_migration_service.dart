import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/vault_item.dart';
import '../domain/vault_repository.dart';

class VaultMigrationService {
  static const String _storageKey = 'vault_items';

  /// Reads any vault items stored locally in SharedPreferences and upserts
  /// them into the provided [repository] (Supabase-backed).
  /// On success, clears the local key so the migration never runs again.
  Future<void> migrateIfNeeded(VaultRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) return;

    List<dynamic> decoded;
    try {
      decoded = jsonDecode(jsonString) as List<dynamic>;
    } catch (_) {
      // Corrupt data — clear it and move on.
      await prefs.remove(_storageKey);
      return;
    }

    if (decoded.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }

    final items = decoded
        .map((e) => VaultItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    for (final item in items) {
      // upsert semantics: if the row already exists (e.g. partial migration),
      // addItem will throw a unique-key conflict — we catch and skip it.
      try {
        await repository.addItem(item);
      } catch (_) {
        // Already migrated — skip.
      }
    }

    await prefs.remove(_storageKey);
  }
}
