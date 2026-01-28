import 'package:careclaim/core/models/claim.dart';
import 'package:careclaim/core/services/local_storage_service.dart';

/// Repository responsible for persisting and loading claims
/// from the underlying [LocalStorageService].
class ClaimsRepository {
  ClaimsRepository(this._storage);

  final LocalStorageService _storage;

  Future<List<Claim>> getClaims() async {
    return _storage.loadClaims();
  }

  Future<void> saveClaims(List<Claim> claims) async {
    await _storage.saveClaims(claims);
  }
}

