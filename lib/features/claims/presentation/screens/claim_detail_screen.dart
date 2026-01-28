import 'package:careclaim/core/models/claim.dart';
import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/features/claims/presentation/screens/claim_edit_screen.dart';
import 'package:careclaim/features/claims/state/claims_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimDetailScreen extends ConsumerWidget {
  const ClaimDetailScreen({super.key, required this.claimId});

  final String claimId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(claimsNotifierProvider);
    final notifier = ref.read(claimsNotifierProvider.notifier);

    Claim? found;
    for (final c in state.claims) {
      if (c.id == claimId) {
        found = c;
        break;
      }
    }

    if (found == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Claim Details'),
        ),
        body: const Center(
          child: Text('Claim not found.'),
        ),
      );
    }

    final claim = found;
    final allowedStatuses = notifier.allowedNextStatuses(claim);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Details'),
        actions: [
          IconButton(
            tooltip: 'Edit claim',
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ClaimEditScreen(claim: claim),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Delete claim',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete claim?'),
                      content: const Text(
                        'This action cannot be undone. Are you sure you want '
                        'to delete this claim?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (!confirmed) return;

              await notifier.deleteClaim(claim.id);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            final left = _buildLeftColumn(context, claim);
            final right = _buildRightColumn(
              context,
              claim,
              allowedStatuses,
              notifier,
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 320,
                    child: right,
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(height: 24),
                  right,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context, Claim claim) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          claim.patient.name,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          claim.patient.policyDetails ?? 'No policy details',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _InfoChip(
              label: 'Contact',
              value: claim.patient.contact ?? '-',
            ),
            _InfoChip(
              label: 'Age',
              value: claim.patient.age?.toString() ?? '-',
            ),
            _InfoChip(
              label: 'Gender',
              value: claim.patient.gender ?? '-',
            ),
            _InfoChip(
              label: 'Created',
              value: _formatDateTime(claim.createdAt),
            ),
            _InfoChip(
              label: 'Updated',
              value: _formatDateTime(claim.updatedAt),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Bills',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildBillsList(context, claim),
        const SizedBox(height: 24),
        Text(
          'Advances',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildAdvancesList(context, claim),
        const SizedBox(height: 24),
        Text(
          'Settlements',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildSettlementsList(context, claim),
      ],
    );
  }

  Widget _buildRightColumn(
    BuildContext context,
    Claim claim,
    List<ClaimStatus> allowedStatuses,
    ClaimsNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final allStatusOptions = [claim.status, ...allowedStatuses].toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Totals',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _TotalRow(
                  label: 'Total bill',
                  value: claim.totalBill,
                ),
                _TotalRow(
                  label: 'Total advances',
                  value: claim.totalAdvances,
                ),
                _TotalRow(
                  label: 'Total settlements',
                  value: claim.totalSettlements,
                ),
                const Divider(height: 24),
                _TotalRow(
                  label: 'Pending amount',
                  value: claim.pendingAmount,
                  isEmphasized: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusPill(status: claim.status),
                    if (claim.pendingAmount == 0 &&
                        (claim.status == ClaimStatus.approved ||
                            claim.status == ClaimStatus.partiallySettled))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Fully settled',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (allowedStatuses.isEmpty)
                  Text(
                    'No further status changes allowed.',
                    style: theme.textTheme.bodySmall,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change status',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ClaimStatus>(
                        value: claim.status,
                        items: allStatusOptions
                            .map(
                              (status) => DropdownMenuItem<ClaimStatus>(
                                value: status,
                                child: Text(_statusLabel(status)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) async {
                          if (value == null || value == claim.status) return;
                          try {
                            await notifier.changeStatus(claim.id, value);
                          } on StateError catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillsList(BuildContext context, Claim claim) {
    if (claim.bills.isEmpty) {
      return const _EmptyLabel('No bills added.');
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: claim.bills.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final bill = claim.bills[index];
          return ListTile(
            title: Text(bill.description),
            subtitle: Text(
              '${bill.category} • ${_formatDate(bill.date)}',
            ),
            trailing: Text(bill.amount.toStringAsFixed(2)),
          );
        },
      ),
    );
  }

  Widget _buildAdvancesList(BuildContext context, Claim claim) {
    if (claim.advances.isEmpty) {
      return const _EmptyLabel('No advances recorded.');
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: claim.advances.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final adv = claim.advances[index];
          return ListTile(
            title: Text(adv.amount.toStringAsFixed(2)),
            subtitle: Text(_formatDate(adv.date)),
            trailing: adv.notes == null ? null : Text(adv.notes!),
          );
        },
      ),
    );
  }

  Widget _buildSettlementsList(BuildContext context, Claim claim) {
    if (claim.settlements.isEmpty) {
      return const _EmptyLabel('No settlements recorded.');
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: claim.settlements.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final s = claim.settlements[index];
          return ListTile(
            title: Text(s.amount.toStringAsFixed(2)),
            subtitle: Text(_formatDate(s.date)),
            trailing: s.notes == null ? null : Text(s.notes!),
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.value,
    this.isEmphasized = false,
  });

  final String label;
  final double value;
  final bool isEmphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isEmphasized
        ? theme.textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toStringAsFixed(2),
            style: style,
          ),
        ],
      ),
    );
  }
}

class _EmptyLabel extends StatelessWidget {
  const _EmptyLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ClaimStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color color;
    switch (status) {
      case ClaimStatus.draft:
        color = scheme.outline;
        break;
      case ClaimStatus.submitted:
        color = scheme.primary;
        break;
      case ClaimStatus.approved:
        color = scheme.secondary;
        break;
      case ClaimStatus.rejected:
        color = scheme.error;
        break;
      case ClaimStatus.partiallySettled:
        color = scheme.tertiary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _statusLabel(status),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
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

String _formatDateTime(DateTime dateTime) {
  final date = _formatDate(dateTime);
  final time =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return '$date • $time';
}

