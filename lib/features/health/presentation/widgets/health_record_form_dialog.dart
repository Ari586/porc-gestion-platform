import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/health_record.dart';
import '../../../../theme/app_colors.dart';

class HealthRecordFormDialog extends StatefulWidget {
  final HealthRecord? record;

  const HealthRecordFormDialog({super.key, this.record});

  static Future<HealthRecord?> show(
    BuildContext context, {
    HealthRecord? record,
  }) {
    return showDialog<HealthRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => HealthRecordFormDialog(record: record),
    );
  }

  @override
  State<HealthRecordFormDialog> createState() => _HealthRecordFormDialogState();
}

class _HealthRecordFormDialogState extends State<HealthRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _animalCodeCtrl;
  late final TextEditingController _productCtrl;
  late final TextEditingController _doseCtrl;
  late final TextEditingController _reasonCtrl;
  late final TextEditingController _responsibleCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _eventDate;
  DateTime? _nextDate;
  String _animalType = 'Truie';
  String _eventType = 'Vaccination';

  static const _animalTypes = ['Truie', 'Verrat', 'Porcelet'];
  static const _eventTypes = ['Vaccination', 'Traitement', 'Contrôle', 'Autre'];

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _animalCodeCtrl = TextEditingController(text: r?.animalCode ?? '');
    _productCtrl = TextEditingController(text: r?.product ?? '');
    _doseCtrl = TextEditingController(text: r?.dose ?? '');
    _reasonCtrl = TextEditingController(text: r?.reason ?? '');
    _responsibleCtrl = TextEditingController(text: r?.responsible ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _eventDate = r?.eventDate;
    _nextDate = r?.nextDate;
    _animalType = (r?.animalType != null && _animalTypes.contains(r!.animalType))
        ? r.animalType
        : 'Truie';
    _eventType = (r?.eventType != null && _eventTypes.contains(r!.eventType))
        ? r.eventType
        : 'Vaccination';
  }

  @override
  void dispose() {
    _animalCodeCtrl.dispose();
    _productCtrl.dispose();
    _doseCtrl.dispose();
    _reasonCtrl.dispose();
    _responsibleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEvent}) async {
    final initial = (isEvent ? _eventDate : _nextDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      helpText: isEvent ? 'Date de l\'événement' : 'Prochaine date',
    );
    if (picked != null) {
      setState(() => isEvent ? _eventDate = picked : _nextDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date de l\'événement.')),
      );
      return;
    }

    Navigator.of(context).pop(HealthRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      animalType: _animalType,
      animalCode: _animalCodeCtrl.text.trim(),
      eventType: _eventType,
      eventDate: _eventDate!,
      product: _productCtrl.text.trim(),
      dose: _doseCtrl.text.trim(),
      reason: _reasonCtrl.text.trim(),
      nextDate: _nextDate,
      responsible: _responsibleCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(AppSpacing.s24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.stethoscope,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Modifier l\'événement' : 'Ajouter un événement santé',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),

                _label('Type d\'animal'),
                const SizedBox(height: AppSpacing.s4),
                DropdownButtonFormField<String>(
                  initialValue: _animalType,
                  decoration: _dec(null),
                  items: _animalTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _animalType = v); },
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Code animal *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _animalCodeCtrl,
                  decoration: _dec('Ex: T-042'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code animal requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Type d\'événement'),
                const SizedBox(height: AppSpacing.s4),
                DropdownButtonFormField<String>(
                  initialValue: _eventType,
                  decoration: _dec(null),
                  items: _eventTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _eventType = v); },
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Date de l\'événement *'),
                const SizedBox(height: AppSpacing.s4),
                _datePicker(
                  date: _eventDate,
                  hint: 'Sélectionner',
                  onTap: () => _pickDate(isEvent: true),
                  fmt: fmt,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Produit *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _productCtrl,
                  decoration: _dec('Ex: Parvo/Erysipele'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Produit requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Dose *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _doseCtrl,
                  decoration: _dec('Ex: 2 mL'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Dose requise' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Motif *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _reasonCtrl,
                  decoration: _dec('Ex: Protocole reproductrice'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Motif requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Responsable *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _responsibleCtrl,
                  decoration: _dec('Ex: Dr. Rabe'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Responsable requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Prochaine date'),
                const SizedBox(height: AppSpacing.s4),
                _datePicker(
                  date: _nextDate,
                  hint: 'Optionnel',
                  onTap: () => _pickDate(isEvent: false),
                  fmt: fmt,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Notes'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: _dec('Observations...'),
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.s24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(LucideIcons.save, size: 16),
                      label: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
      );

  Widget _datePicker({
    required DateTime? date,
    required String hint,
    required VoidCallback onTap,
    required DateFormat fmt,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(LucideIcons.calendar, size: 16, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.s8),
            Text(
              date != null ? fmt.format(date) : hint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: date != null ? AppColors.textPrimary : AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String? hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error)),
      );
}
