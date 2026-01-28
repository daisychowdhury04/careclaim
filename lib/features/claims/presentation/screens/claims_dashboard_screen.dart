import 'package:careclaim/core/models/claim.dart';
import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/features/claims/presentation/screens/claim_detail_screen.dart';
import 'package:careclaim/features/claims/presentation/screens/claim_edit_screen.dart';
import 'package:careclaim/features/claims/presentation/screens/claims_analysis_screen.dart';
import 'package:careclaim/features/claims/state/claims_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimsDashboardScreen extends ConsumerStatefulWidget {
  const ClaimsDashboardScreen({super.key});

  @override
  ConsumerState<ClaimsDashboardScreen> createState() =>
      _ClaimsDashboardScreenState();
}

class _ClaimsDashboardScreenState
    extends ConsumerState<ClaimsDashboardScreen> {
  ClaimStatus? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final claimsState = ref.watch(claimsNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareClaim – Claims Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Analysis',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ClaimsAnalysisScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8ECFF),
                Color(0xFFF5F7FB),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.health_and_safety_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your insurance claims at a glance',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _StatusFilterChips(
                  selectedStatus: _statusFilter,
                  onStatusSelected: (status) {
                    setState(() => _statusFilter = status);
                  },
                ),
                const SizedBox(height: 16),
                _SummaryRow(claims: claimsState.claims),
                const SizedBox(height: 16),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (claimsState.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (claimsState.errorMessage != null) {
                        return Center(
                          child: Card(
                            color: theme.colorScheme.errorContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: theme
                                        .colorScheme.onErrorContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      claimsState.errorMessage!,
                                      style: TextStyle(
                                        color: theme
                                            .colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final filteredClaims = _statusFilter == null
                          ? claimsState.claims
                          : claimsState.claims
                              .where((c) => c.status == _statusFilter)
                              .toList();

                      if (filteredClaims.isEmpty) {
                        return Center(
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 40,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No claims yet',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Get started by creating your first claim.',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                      color: theme
                                          .colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: filteredClaims.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final claim = filteredClaims[index];
                            return _ClaimListTile(claim: claim);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ClaimEditScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Claim'),
      ),
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final ClaimStatus? selectedStatus;
  final ValueChanged<ClaimStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      ClaimStatus.draft,
      ClaimStatus.submitted,
      ClaimStatus.approved,
      ClaimStatus.rejected,
      ClaimStatus.partiallySettled,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('All'),
            selected: selectedStatus == null,
            onSelected: (_) => onStatusSelected(null),
          ),
          const SizedBox(width: 8),
          for (final status in statuses) ...[
            ChoiceChip(
              label: Text(_statusLabel(status)),
              selected: selectedStatus == status,
              onSelected: (_) => onStatusSelected(status),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.claims});

  final List<Claim> claims;

  @override
  Widget build(BuildContext context) {
    final totalPending =
        claims.fold<double>(0, (sum, c) => sum + c.pendingAmount);

    int countFor(ClaimStatus status) =>
        claims.where((c) => c.status == status).length;

    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer.withOpacity(0.8),
            theme.colorScheme.secondaryContainer.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          final cards = [
            _SummaryCard(
              title: 'Total claims',
              value: claims.length.toString(),
              icon: Icons.folder_copy_outlined,
            ),
            _SummaryCard(
              title: 'Total pending',
              value: totalPending.toStringAsFixed(2),
              icon: Icons.account_balance_wallet_outlined,
            ),
            _SummaryCard(
              title: 'Draft',
              value: countFor(ClaimStatus.draft).toString(),
              icon: Icons.edit_note_outlined,
            ),
            _SummaryCard(
              title: 'Submitted',
              value: countFor(ClaimStatus.submitted).toString(),
              icon: Icons.send_outlined,
            ),
            _SummaryCard(
              title: 'Approved',
              value: countFor(ClaimStatus.approved).toString(),
              icon: Icons.check_circle_outline,
            ),
          ];

          if (isWide) {
            return Row(
              children: cards
                  .map(
                    (card) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: cards
                  .map(
                    (card) => SizedBox(
                      width: 200,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: card,
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.04),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClaimListTile extends StatelessWidget {
  const _ClaimListTile({required this.claim});

  final Claim claim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ClaimDetailScreen(claimId: claim.id),
          ),
        );
      },
      title: Text(claim.patient.name),
      subtitle: Text(
        'Pending: ${claim.pendingAmount.toStringAsFixed(2)} • '
        'Updated: ${_formatDate(claim.updatedAt)}',
      ),
      trailing: _StatusBadge(status: claim.status),
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          claim.patient.name.isNotEmpty
              ? claim.patient.name[0].toUpperCase()
              : '?',
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    final text = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

Color _statusColor(BuildContext context, ClaimStatus status) {
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case ClaimStatus.draft:
      return scheme.outline;
    case ClaimStatus.submitted:
      return scheme.primary;
    case ClaimStatus.approved:
      return scheme.secondary;
    case ClaimStatus.rejected:
      return scheme.error;
    case ClaimStatus.partiallySettled:
      return scheme.tertiary;
  }
}

String _statusLabel(ClaimStatus status) {
  switch (status) {
    case ClaimStatus.draft:
      return 'Draft';
    case ClaimStatus.submitted:
      return 'Submitted';
    case ClaimStatus.approved:
      return 'Approved';
    case ClaimStatus.rejected:
      return 'Rejected';
    case ClaimStatus.partiallySettled:
      return 'Partially Settled';
  }
}

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

