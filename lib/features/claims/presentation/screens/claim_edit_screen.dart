import 'package:careclaim/core/models/advance_payment.dart';
import 'package:careclaim/core/models/bill_item.dart';
import 'package:careclaim/core/models/claim.dart';
import 'package:careclaim/core/models/claim_status.dart';
import 'package:careclaim/core/models/patient.dart';
import 'package:careclaim/core/models/settlement.dart';
import 'package:careclaim/core/services/id_generator.dart';
import 'package:careclaim/features/claims/state/claims_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClaimEditScreen extends ConsumerStatefulWidget {
  const ClaimEditScreen({super.key, this.claim});

  final Claim? claim;

  @override
  ConsumerState<ClaimEditScreen> createState() => _ClaimEditScreenState();
}

class _ClaimEditScreenState extends ConsumerState<ClaimEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _patientNameController;
  late final TextEditingController _policyDetailsController;
  late final TextEditingController _contactController;
  late final TextEditingController _ageController;

  String? _selectedGender;

  late List<BillItem> _bills;
  late List<AdvancePayment> _advances;
  late List<Settlement> _settlements;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final claim = widget.claim;

    _patientNameController =
        TextEditingController(text: claim?.patient.name ?? '');
    _policyDetailsController =
        TextEditingController(text: claim?.patient.policyDetails ?? '');
    _contactController =
        TextEditingController(text: claim?.patient.contact ?? '');
    _ageController =
        TextEditingController(text: claim?.patient.age?.toString() ?? '');
    _selectedGender = claim?.patient.gender;

    _bills = List<BillItem>.from(claim?.bills ?? const []);
    _advances = List<AdvancePayment>.from(claim?.advances ?? const []);
    _settlements = List<Settlement>.from(claim?.settlements ?? const []);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _policyDetailsController.dispose();
    _contactController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool get _isEditMode => widget.claim != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Claim' : 'New Claim'),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.surfaceVariant.withOpacity(0.35),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                final left = _buildPatientAndLists(theme);
                final right = _buildTotalsAndActions(theme);

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: left,
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: right,
                        ),
                      ),
                    ],
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
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
        ),
      ),
    );
  }

  Widget _buildPatientAndLists(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient & claim details',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Basic information about the insured patient and policy.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient name *',
                    helperText: 'Full name as it appears on the policy',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Patient name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _policyDetailsController,
                  decoration: const InputDecoration(
                    labelText: 'Policy / member ID',
                    helperText: 'Policy number or member identifier (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact',
                          helperText: 'Phone or email for follow-up (optional)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 90,
                      child: TextFormField(
                        controller: _ageController,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Male',
                            child: Text('Male'),
                          ),
                          DropdownMenuItem(
                            value: 'Female',
                            child: Text('Female'),
                          ),
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                          DropdownMenuItem(
                            value: 'Prefer not to say',
                            child: Text('Prefer not to say'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildBillsSection(theme),
        const SizedBox(height: 24),
        _buildAdvancesSection(theme),
        const SizedBox(height: 24),
        _buildSettlementsSection(theme),
      ],
    );
  }

  Widget _buildBillsSection(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bills',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _showBillDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add bill'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Itemized charges such as consultations, lab tests, pharmacy, room, etc.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_bills.isEmpty)
              Text(
                'No bills added yet. Tap "Add bill" to capture the first item.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _bills.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final bill = _bills[index];
                  return ListTile(
                    title: Text(bill.description),
                    subtitle: Text(
                      '${bill.category} • ${_formatDate(bill.date)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(bill.amount.toStringAsFixed(2)),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _bills.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancesSection(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advances',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _showAdvanceDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add advance'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Any advance amounts paid by the insurer or patient before settlement.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_advances.isEmpty)
              Text(
                'No advances recorded.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _advances.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final adv = _advances[index];
                  return ListTile(
                    title: Text(adv.amount.toStringAsFixed(2)),
                    subtitle: Text(_formatDate(adv.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (adv.notes != null) Text(adv.notes!),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _advances.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettlementsSection(ThemeData theme) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Settlements',
                  style: theme.textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _showSettlementDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Add settlement'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Final payments made by the insurer against this claim.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_settlements.isEmpty)
              Text(
                'No settlements recorded.',
                style: theme.textTheme.bodyMedium,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _settlements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = _settlements[index];
                  return ListTile(
                    title: Text(s.amount.toStringAsFixed(2)),
                    subtitle: Text(_formatDate(s.date)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.notes != null) Text(s.notes!),
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _settlements.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalsAndActions(ThemeData theme) {
    final totalBill = _bills.fold<double>(0, (sum, b) => sum + b.amount);
    final totalAdvances =
        _advances.fold<double>(0, (sum, a) => sum + a.amount);
    final totalSettlements =
        _settlements.fold<double>(0, (sum, s) => sum + s.amount);
    final pending = totalBill - totalAdvances - totalSettlements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Totals (preview)',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _TotalPreviewRow(label: 'Total bill', value: totalBill),
                _TotalPreviewRow(label: 'Total advances', value: totalAdvances),
                _TotalPreviewRow(
                  label: 'Total settlements',
                  value: totalSettlements,
                ),
                const Divider(height: 24),
                _TotalPreviewRow(
                  label: 'Pending amount',
                  value: pending,
                  isEmphasized: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Final totals will be recalculated and validated when you save.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isSaving ? null : () => _saveClaim(draft: true),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save as draft'),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _isSaving || _bills.isEmpty
              ? null
              : () => _saveClaim(draft: false),
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Submit'),
        ),
        const SizedBox(height: 8),
        Text(
          'Submit is enabled when at least one bill exists and patient name '
          'is filled.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _saveClaim({required bool draft}) async {
    if (!_formKey.currentState!.validate()) return;

    if (!draft && _bills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('At least one bill is required to submit a claim.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final notifier = ref.read(claimsNotifierProvider.notifier);
    final now = DateTime.now();

    final existing = widget.claim;
    final patient = Patient(
      id: existing?.patient.id ?? generateId(),
      name: _patientNameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      gender: _selectedGender,
      contact: _contactController.text.trim().isEmpty
          ? null
          : _contactController.text.trim(),
      policyDetails: _policyDetailsController.text.trim().isEmpty
          ? null
          : _policyDetailsController.text.trim(),
    );

    final claimStatus = draft
        ? ClaimStatus.draft
        : (existing?.status ?? ClaimStatus.submitted);

    final claim = Claim(
      id: existing?.id ?? generateId(),
      patient: patient,
      bills: _bills,
      advances: _advances,
      settlements: _settlements,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      status: claimStatus,
      totalBill: 0,
      totalAdvances: 0,
      totalSettlements: 0,
      pendingAmount: 0,
    );

    await notifier.upsertClaim(claim);

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _showBillDialog() async {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedCategory;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Add bill'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category *',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Consultation',
                      child: Text('Consultation'),
                    ),
                    DropdownMenuItem(
                      value: 'Lab / diagnostics',
                      child: Text('Lab / diagnostics'),
                    ),
                    DropdownMenuItem(
                      value: 'Pharmacy',
                      child: Text('Pharmacy'),
                    ),
                    DropdownMenuItem(
                      value: 'Room / ward',
                      child: Text('Room / ward'),
                    ),
                    DropdownMenuItem(
                      value: 'Procedure / surgery',
                      child: Text('Procedure / surgery'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedCategory = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select a category';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    final amount = double.tryParse(text);
                    if (amount == null || amount < 0) {
                      return 'Enter a valid non-negative amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final amount = double.parse(amountController.text.trim());
      setState(() {
        _bills.add(
          BillItem(
            id: generateId(),
            description: descriptionController.text.trim(),
            category: selectedCategory ?? 'Other',
            amount: amount,
            date: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _showAdvanceDialog() async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Add advance'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    final amount = double.tryParse(text);
                    if (amount == null || amount < 0) {
                      return 'Enter a valid non-negative amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final amount = double.parse(amountController.text.trim());
      setState(() {
        _advances.add(
          AdvancePayment(
            id: generateId(),
            date: DateTime.now(),
            amount: amount,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          ),
        );
      });
    }
  }

  Future<void> _showSettlementDialog() async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Add settlement'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount *',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    final amount = double.tryParse(text);
                    if (amount == null || amount < 0) {
                      return 'Enter a valid non-negative amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final amount = double.parse(amountController.text.trim());
      setState(() {
        _settlements.add(
          Settlement(
            id: generateId(),
            date: DateTime.now(),
            amount: amount,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          ),
        );
      });
    }
  }
}

class _TotalPreviewRow extends StatelessWidget {
  const _TotalPreviewRow({
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

String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}

