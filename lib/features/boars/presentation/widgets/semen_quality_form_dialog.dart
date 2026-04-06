import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/semen_quality_record.dart';
import '../../../../theme/app_colors.dart';

class SemenQualityFormDialog extends StatefulWidget {
  final SemenQualityRecord? record;

  const SemenQualityFormDialog({super.key, this.record});

  static Future<SemenQualityRecord?> show(BuildContext context,
      {SemenQualityRecord? record}) {
    return showDialog<SemenQualityRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SemenQualityFormDialog(record: record),
    );
  }

  @override
  State<SemenQualityFormDialog> createState() => _SemenQualityFormDialogState();
}

class _SemenQualityFormDialogState extends State<SemenQualityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _lotCodeCtrl;
  late final TextEditingController _boarCodeCtrl;
  late final TextEditingController _concentrationCtrl;
  late final TextEditingController _motilityCtrl;
  late final TextEditingController _temperatureCtrl;
  late final TextEditingController _storageHoursCtrl;
  late final TextEditingController _approvedByCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _collectionDate;

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _lotCodeCtrl = TextEditingController(text: r?.lotCode ?? '');
    _boarCodeCtrl = TextEditingController(text: r?.boarCode ?? '');
    _concentrationCtrl = TextEditingController(
        text: r != null ? r.concentration.toString() : '');
    _motilityCtrl = TextEditingController(
        text: r != null ? r.motilityPercent.toString() : '');
    _temperatureCtrl = TextEditingController(
        text: r != null ? r.temperatureC.toString() : '');
    _storageHoursCtrl = TextEditingController(
        text: r != null ? r.storageHours.toString() : '');
    _approvedByCtrl = TextEditingController(text: r?.approvedBy ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _collectionDate = r?.collectionDate;
  }

  @override
  void dispose() {
    _lotCodeCtrl.dispose();
    _boarCodeCtrl.dispose();
    _concentrationCtrl.dispose();
    _motilityCtrl.dispose();
    _temperatureCtrl.dispose();
    _storageHoursCtrl.dispose();
    _approvedByCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _collectionDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _collectionDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_collectionDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date de collecte')),
      );
      return;
    }

    final record = SemenQualityRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      lotCode: _lotCodeCtrl.text.trim(),
      boarCode: _boarCodeCtrl.text.trim(),
      collectionDate: _collectionDate!,
      concentration: double.tryParse(_concentrationCtrl.text.trim()) ?? 0,
      motilityPercent: double.tryParse(_motilityCtrl.text.trim()) ?? 0,
      temperatureC: double.tryParse(_temperatureCtrl.text.trim()) ?? 0,
      storageHours: int.tryParse(_storageHoursCtrl.text.trim()) ?? 0,
      approvedBy: _approvedByCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Dialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  const Icon(LucideIcons.testTube, color: AppColors.primary, size: 22),
                  const SizedBox(width: AppSpacing.s10),
                  Text(
                    _isEditing ? 'Modifier le contrôle' : 'Nouveau contrôle qualité',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ]),
                const SizedBox(height: AppSpacing.s20),

                _buildField(_lotCodeCtrl, 'Code lot *', 'Ex: LOT-2026-04A', LucideIcons.hash,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                const SizedBox(height: AppSpacing.s12),

                _buildField(_boarCodeCtrl, 'Code verrat *', 'Ex: V-008', LucideIcons.piggyBank,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                const SizedBox(height: AppSpacing.s12),

                // Collection date
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date de collecte *',
                        hintText: 'Sélectionner',
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      controller: TextEditingController(
                        text: _collectionDate != null ? dateFmt.format(_collectionDate!) : '',
                      ),
                      validator: (_) => _collectionDate == null ? 'Date requise' : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                Row(children: [
                  Expanded(child: _buildField(_concentrationCtrl, 'Concentration (M/mL) *', '200', LucideIcons.droplets,
                      keyboardType: TextInputType.number, validator: _requiredNumber)),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(child: _buildField(_motilityCtrl, 'Motilité (%) *', '85', LucideIcons.activity,
                      keyboardType: TextInputType.number, validator: _requiredNumber)),
                ]),
                const SizedBox(height: AppSpacing.s12),

                Row(children: [
                  Expanded(child: _buildField(_temperatureCtrl, 'Température (°C) *', '37', LucideIcons.thermometer,
                      keyboardType: TextInputType.number, validator: _requiredNumber)),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(child: _buildField(_storageHoursCtrl, 'Stockage (h)', '0', LucideIcons.clock,
                      keyboardType: TextInputType.number)),
                ]),
                const SizedBox(height: AppSpacing.s12),

                _buildField(_approvedByCtrl, 'Approuvé par *', 'Ex: Dr. Rabe', LucideIcons.userCheck,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                const SizedBox(height: AppSpacing.s12),

                _buildField(_notesCtrl, 'Notes', 'Observations...', LucideIcons.fileText, maxLines: 2),
                const SizedBox(height: AppSpacing.s20),

                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                  const SizedBox(width: AppSpacing.s12),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: Icon(_isEditing ? LucideIcons.save : LucideIcons.plus, size: 16),
                    label: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requis';
    if (double.tryParse(v.trim()) == null) return 'Nombre invalide';
    return null;
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
