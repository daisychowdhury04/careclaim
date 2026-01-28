import 'dart:math';

import 'package:careclaim/core/models/advance_payment.dart';
import 'package:careclaim/core/models/bill_item.dart';
import 'package:careclaim/core/models/claim.dart';
import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/core/models/patient.dart';
import 'package:careclaim/core/models/settlement.dart';
import 'package:careclaim/core/services/local_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/claims_repository.dart';

class ClaimsState {
  const ClaimsState({
    required this.claims,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Claim> claims;
  final bool isLoading;
  final String? errorMessage;

  factory ClaimsState.initial() => const ClaimsState(
        claims: <Claim>[],
        isLoading: true,
      );

  ClaimsState copyWith({
    List<Claim>? claims,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClaimsState(
      claims: claims ?? this.claims,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ClaimsNotifier extends StateNotifier<ClaimsState> {
  ClaimsNotifier(this._repository) : super(ClaimsState.initial()) {
    _loadInitialClaims();
  }

  final ClaimsRepository _repository;

  Future<void> _loadInitialClaims() async {
    try {
      final claims = await _repository.getClaims();

      // If there are no persisted claims yet, seed some dummy data so that
      // all status tabs have something to display.
      if (claims.isEmpty) {
        final demoClaims = _createDemoClaims()
            .map(_recalculateClaim)
            .toList(growable: false);
        await _persist(demoClaims);
        state = state.copyWith(
          claims: demoClaims,
          isLoading: false,
          errorMessage: null,
        );
        return;
      }

      state = state.copyWith(
        claims: claims.map(_recalculateClaim).toList(growable: false),
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load claims: $e',
      );
    }
  }

  Future<void> _persist(List<Claim> claims) async {
    await _repository.saveClaims(claims);
    state = state.copyWith(claims: claims, errorMessage: null);
  }

  /// Returns a new [Claim] instance with all derived fields recalculated.
  Claim _recalculateClaim(Claim claim) {
    final totalBill = claim.bills.fold<double>(
      0.0,
      (sum, item) => sum + max(0.0, item.amount),
    );
    final totalAdvances = claim.advances.fold<double>(
      0.0,
      (sum, item) => sum + max(0.0, item.amount),
    );
    final totalSettlements = claim.settlements.fold<double>(
      0.0,
      (sum, item) => sum + max(0.0, item.amount),
    );
    final pending = max(
      0.0,
      totalBill - totalAdvances - totalSettlements,
    ); // never < 0

    return Claim(
      id: claim.id,
      patient: claim.patient,
      bills: claim.bills,
      advances: claim.advances,
      settlements: claim.settlements,
      totalBill: totalBill,
      totalAdvances: totalAdvances,
      totalSettlements: totalSettlements,
      pendingAmount: pending,
      status: claim.status,
      createdAt: claim.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  int _indexOfClaim(String claimId) =>
      state.claims.indexWhere((c) => c.id == claimId);

  /// Replace (or insert) a whole [Claim], recalculating totals first.
  Future<void> upsertClaim(Claim claim) async {
    final updated = _recalculateClaim(claim);
    final claims = [...state.claims];
    final index = _indexOfClaim(updated.id);

    if (index >= 0) {
      claims[index] = updated;
    } else {
      claims.add(updated);
    }

    await _persist(claims);
  }

  Future<void> deleteClaim(String claimId) async {
    final claims =
        state.claims.where((claim) => claim.id != claimId).toList(growable: false);
    await _persist(claims);
  }

  Future<void> addBillItem(String claimId, BillItem billItem) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: [...claim.bills, billItem],
        advances: claim.advances,
        settlements: claim.settlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> editBillItem(String claimId, BillItem billItem) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedBills = [
      for (final b in claim.bills) if (b.id == billItem.id) billItem else b,
    ];

    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: updatedBills,
        advances: claim.advances,
        settlements: claim.settlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> removeBillItem(String claimId, String billItemId) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedBills =
        claim.bills.where((bill) => bill.id != billItemId).toList();

    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: updatedBills,
        advances: claim.advances,
        settlements: claim.settlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> addAdvance(String claimId, AdvancePayment advance) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: claim.bills,
        advances: [...claim.advances, advance],
        settlements: claim.settlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> removeAdvance(String claimId, String advanceId) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedAdvances =
        claim.advances.where((adv) => adv.id != advanceId).toList();

    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: claim.bills,
        advances: updatedAdvances,
        settlements: claim.settlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> addSettlement(String claimId, Settlement settlement) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: claim.bills,
        advances: claim.advances,
        settlements: [...claim.settlements, settlement],
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  Future<void> removeSettlement(String claimId, String settlementId) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final claim = state.claims[index];
    final updatedSettlements =
        claim.settlements.where((s) => s.id != settlementId).toList();

    final updatedClaim = _recalculateClaim(
      Claim(
        id: claim.id,
        patient: claim.patient,
        bills: claim.bills,
        advances: claim.advances,
        settlements: updatedSettlements,
        totalBill: claim.totalBill,
        totalAdvances: claim.totalAdvances,
        totalSettlements: claim.totalSettlements,
        pendingAmount: claim.pendingAmount,
        status: claim.status,
        createdAt: claim.createdAt,
        updatedAt: claim.updatedAt,
      ),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  /// Status transition rules based on the implementation plan:
  /// - Draft → Submitted
  /// - Submitted → Approved | Rejected | PartiallySettled
  /// - Approved → PartiallySettled
  /// - PartiallySettled → Approved
  /// - Rejected → Draft
  List<ClaimStatus> allowedNextStatuses(Claim claim) {
    switch (claim.status) {
      case ClaimStatus.draft:
        return const [ClaimStatus.submitted];
      case ClaimStatus.submitted:
        return const [
          ClaimStatus.approved,
          ClaimStatus.rejected,
          ClaimStatus.partiallySettled,
        ];
      case ClaimStatus.approved:
        return const [ClaimStatus.partiallySettled];
      case ClaimStatus.rejected:
        return const [ClaimStatus.draft];
      case ClaimStatus.partiallySettled:
        return const [ClaimStatus.approved];
    }
  }

  Future<void> changeStatus(String claimId, ClaimStatus newStatus) async {
    final index = _indexOfClaim(claimId);
    if (index == -1) return;

    final currentClaim = _recalculateClaim(state.claims[index]);
    final allowed = allowedNextStatuses(currentClaim);
    if (!allowed.contains(newStatus)) {
      throw StateError(
        'Invalid status transition from ${currentClaim.status} to $newStatus',
      );
    }

    // Optional but realistic rule: only allow Approved/PartiallySettled
    // when there is at least one advance or settlement.
    if ((newStatus == ClaimStatus.approved ||
            newStatus == ClaimStatus.partiallySettled) &&
        currentClaim.advances.isEmpty &&
        currentClaim.settlements.isEmpty) {
      throw StateError(
        'Cannot mark claim as approved or partially settled without any '
        'advance or settlement.',
      );
    }

    final updatedClaim = Claim(
      id: currentClaim.id,
      patient: currentClaim.patient,
      bills: currentClaim.bills,
      advances: currentClaim.advances,
      settlements: currentClaim.settlements,
      totalBill: currentClaim.totalBill,
      totalAdvances: currentClaim.totalAdvances,
      totalSettlements: currentClaim.totalSettlements,
      pendingAmount: currentClaim.pendingAmount,
      status: newStatus,
      createdAt: currentClaim.createdAt,
      updatedAt: DateTime.now(),
    );

    final claims = [...state.claims]..[index] = updatedClaim;
    await _persist(claims);
  }

  /// Create some deterministic dummy claims covering all statuses so
  /// the dashboard filter tabs can be exercised without manual input.
  List<Claim> _createDemoClaims() {
    final now = DateTime.now();

    Claim makeClaim({
      required String id,
      required String name,
      required ClaimStatus status,
      required double billAmount,
      double advanceAmount = 0,
      double settlementAmount = 0,
      String? policy,
      String? gender,
    }) {
      final patient = Patient(
        id: 'patient_$id',
        name: name,
        age: 35,
        gender: gender,
        contact: '+1 555 010$id',
        policyDetails: policy,
      );

      final bill = BillItem(
        id: 'bill_$id',
        description: 'Hospital charges for $name',
        category: 'Consultation',
        amount: billAmount,
        date: now.subtract(const Duration(days: 5)),
      );

      final advances = advanceAmount > 0
          ? <AdvancePayment>[
              AdvancePayment(
                id: 'adv_$id',
                date: now.subtract(const Duration(days: 3)),
                amount: advanceAmount,
                notes: 'Advance paid by insurer',
              ),
            ]
          : const <AdvancePayment>[];

      final settlements = settlementAmount > 0
          ? <Settlement>[
              Settlement(
                id: 'set_$id',
                date: now.subtract(const Duration(days: 1)),
                amount: settlementAmount,
                notes: 'Final settlement',
              ),
            ]
          : const <Settlement>[];

      return Claim(
        id: id,
        patient: patient,
        bills: <BillItem>[bill],
        advances: advances,
        settlements: settlements,
        totalBill: billAmount,
        totalAdvances: advanceAmount,
        totalSettlements: settlementAmount,
        pendingAmount: billAmount - advanceAmount - settlementAmount,
        status: status,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 1)),
      );
    }

    return <Claim>[
      // Draft – just created, no financial activity yet.
      makeClaim(
        id: 'demo_draft_1',
        name: 'Alex Draftson',
        status: ClaimStatus.draft,
        billAmount: 250.0,
        policy: 'POL-DRAFT-001',
        gender: 'Male',
      ),
      // Submitted – bill captured, waiting for review.
      makeClaim(
        id: 'demo_submitted_1',
        name: 'Sara Submitted',
        status: ClaimStatus.submitted,
        billAmount: 480.0,
        policy: 'POL-SUB-001',
        gender: 'Female',
      ),
      // Approved – with an advance/settlement so status rules are satisfied.
      makeClaim(
        id: 'demo_approved_1',
        name: 'Ian Approved',
        status: ClaimStatus.approved,
        billAmount: 1000.0,
        advanceAmount: 400.0,
        settlementAmount: 400.0,
        policy: 'POL-APP-001',
        gender: 'Male',
      ),
      // Rejected – no financial movement.
      makeClaim(
        id: 'demo_rejected_1',
        name: 'Nina Rejected',
        status: ClaimStatus.rejected,
        billAmount: 320.0,
        policy: 'POL-REJ-001',
        gender: 'Female',
      ),
      // Partially settled – some but not all amounts paid.
      makeClaim(
        id: 'demo_partial_1',
        name: 'Peter Partial',
        status: ClaimStatus.partiallySettled,
        billAmount: 1500.0,
        advanceAmount: 300.0,
        settlementAmount: 700.0,
        policy: 'POL-PART-001',
        gender: 'Male',
      ),
    ];
  }
}

/// Riverpod providers wiring together storage, repository, and notifier.
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final claimsRepositoryProvider = Provider<ClaimsRepository>((ref) {
  final storage = ref.read(localStorageServiceProvider);
  return ClaimsRepository(storage);
});

final claimsNotifierProvider =
    StateNotifierProvider<ClaimsNotifier, ClaimsState>((ref) {
  final repository = ref.read(claimsRepositoryProvider);
  return ClaimsNotifier(repository);
});

