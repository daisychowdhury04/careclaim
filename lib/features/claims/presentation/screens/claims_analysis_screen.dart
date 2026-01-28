import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/features/claims/state/claims_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimsAnalysisScreen extends ConsumerWidget {
  const ClaimsAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(claimsNotifierProvider);
    final claims = state.claims;
    final theme = Theme.of(context);

    final totalClaims = claims.length;
    final totalBill = claims.fold<double>(0, (sum, c) => sum + c.totalBill);
    final totalPaid =
        claims.fold<double>(0, (sum, c) => sum + c.totalAdvances + c.totalSettlements);
    final totalPending =
        claims.fold<double>(0, (sum, c) => sum + c.pendingAmount);

    int countFor(ClaimStatus status) =>
        claims.where((c) => c.status == status).length;

    double pendingFor(ClaimStatus status) =>
        claims
            .where((c) => c.status == status)
            .fold<double>(0, (sum, c) => sum + c.pendingAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claims Analysis'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: claims.isEmpty
              ? Center(
                  child: Text(
                    'No claims yet to analyse.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _AnalysisCard(
                            label: 'Total claims',
                            value: totalClaims.toString(),
                            icon: Icons.folder_copy_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          _AnalysisCard(
                            label: 'Total billed',
                            value: totalBill.toStringAsFixed(2),
                            icon: Icons.receipt_long_outlined,
                            color: theme.colorScheme.secondary,
                          ),
                          _AnalysisCard(
                            label: 'Total paid',
                            value: totalPaid.toStringAsFixed(2),
                            icon: Icons.payments_outlined,
                            color: theme.colorScheme.tertiary,
                          ),
                          _AnalysisCard(
                            label: 'Total pending',
                            value: totalPending.toStringAsFixed(2),
                            icon: Icons.account_balance_wallet_outlined,
                            color: theme.colorScheme.error,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'By status',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _StatusRow(
                                label: 'Draft',
                                count: countFor(ClaimStatus.draft),
                                pending: pendingFor(ClaimStatus.draft),
                              ),
                              _StatusRow(
                                label: 'Submitted',
                                count: countFor(ClaimStatus.submitted),
                                pending: pendingFor(ClaimStatus.submitted),
                              ),
                              _StatusRow(
                                label: 'Approved',
                                count: countFor(ClaimStatus.approved),
                                pending: pendingFor(ClaimStatus.approved),
                              ),
                              _StatusRow(
                                label: 'Rejected',
                                count: countFor(ClaimStatus.rejected),
                                pending: pendingFor(ClaimStatus.rejected),
                              ),
                              _StatusRow(
                                label: 'Partially settled',
                                count: countFor(ClaimStatus.partiallySettled),
                                pending: pendingFor(ClaimStatus.partiallySettled),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 190,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.count,
    required this.pending,
  });

  final String label;
  final int count;
  final double pending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 16),
          Text(
            pending.toStringAsFixed(2),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

