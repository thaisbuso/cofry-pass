import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/supabase_vault_repository.dart';
import 'data/vault_migration_service.dart';
import 'domain/vault_repository.dart';

final vaultRepositoryProvider = Provider<VaultRepository>(
  (ref) => SupabaseVaultRepository(),
);

final vaultMigrationServiceProvider = Provider<VaultMigrationService>(
  (ref) => VaultMigrationService(),
);
