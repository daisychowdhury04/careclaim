import 'package:hive_flutter/hive_flutter.dart';

import '../models/advance_payment.dart';
import '../models/bill_item.dart';
import '../models/claim.dart';
import '../models/claim_status.dart';
import '../models/patient.dart';
import '../models/settlement.dart';

class LocalStorageService {
  static const _claimsBoxName = 'claims_box';

  static bool _initialized = false;

  /// Initialize Hive and register all required adapters.
  ///
  /// This method is idempotent and can safely be called multiple times.
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters for all models used by [Claim].
    if (!Hive.isAdapterRegistered(ClaimStatusAdapter().typeId)) {
      Hive.registerAdapter(ClaimStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(PatientAdapter().typeId)) {
      Hive.registerAdapter(PatientAdapter());
    }
    if (!Hive.isAdapterRegistered(BillItemAdapter().typeId)) {
      Hive.registerAdapter(BillItemAdapter());
    }
    if (!Hive.isAdapterRegistered(AdvancePaymentAdapter().typeId)) {
      Hive.registerAdapter(AdvancePaymentAdapter());
    }
    if (!Hive.isAdapterRegistered(SettlementAdapter().typeId)) {
      Hive.registerAdapter(SettlementAdapter());
    }
    if (!Hive.isAdapterRegistered(ClaimAdapter().typeId)) {
      Hive.registerAdapter(ClaimAdapter());
    }

    _initialized = true;
  }

  Future<Box<Claim>> _openClaimsBox() async {
    await init();
    return Hive.openBox<Claim>(_claimsBoxName);
  }

  Future<void> saveClaims(List<Claim> claims) async {
    final box = await _openClaimsBox();
    await box.clear();
    await box.addAll(claims);
  }

  Future<List<Claim>> loadClaims() async {
    final box = await _openClaimsBox();
    return box.values.toList();
  }
}

