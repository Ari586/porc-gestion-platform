import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/insemination_record.dart';
import '../../../../theme/app_colors.dart';

class InseminationFormDialog extends StatefulWidget {
  final InseminationRecord? record;

  const InseminationFormDialog({super.key, this.record});

  static Future<InseminationRecord?> show(
    BuildContext context, {
    InseminationRecord? record,
  }) {
    return showDialog<InseminationRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => InseminationFormDialog(record: record),
    );
  }

  @override
  State<InseminationFormDialog> createState() => _InseminationFormDialogState();
}

class _InseminationFormDialogState extends State<InseminationFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _sowCodeCtrl;
  late final TextEditingController _boarCodeCtrl;
  late final TextEditingController _semenLotCtrl;
  late final TextEditingController _inseminatorCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _dose1Date;
  DateTime? _dose2Date;
  String _status = 'En attente';

  static const _statuses = ['En attente', 'Confirmée', 'Échouée'];

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _sowCodeCtrl = TextEditingController(text: r?.sowCode ?? '');
    _boarCodeCtrl = TextEditingController(text: r?.boarCode ?? '');
    _semenLotCtrl = TextEditingController(text: r?.semenLot ?? '');
    _inseminatorCtrl = TextEditingController(text: r?.inseminator ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _dose1Date = r?.dose1Date;
    _dose2Date = r?.dose2Date;
    _status = r?.status ?? 'En attente';
    if (!_statuses.contains(_status)) _status = 'En attente';
  }

  @override
  void dispose() {
    _sowCodeCtrl.dispose();
    _boarCodeCtrl.dispose();
    _semenLotCtrl.dispose();
    _inseminatorCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDose1}) async {
    final initial = (isDose1 ? _dose1Date : _dose2Date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: isDose1 ? 'Date dose 1' : 'Date dose 2',
    );
    if (picked != null) {
      setState(() => isDose1 ? _dose1Date = picked : _dose2Date = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_dose1Date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date de la dose 1.')),
      );
      return;
    }

    Navigator.of(context).pop(InseminationRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      sowCode: _sowCodeCtrl.text.trim(),
      boarCode: _boarCodeCtrl.text.trim(),
      semenLot: _semenLotCtrl.text.trim(),
      dose1Date: _dose1Date!,
      dose2Date: _dose2Date,
      inseminator: _inseminatorCtrl.text.trim(),
      status: _status,
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
                      child: const Icon(LucideIcons.syringe,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Modifier l\'insémination' : 'Ajouter une insémination',
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

                _label('Code truie *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _sowCodeCtrl,
                  decoration: _dec('Ex: T-042'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code truie requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Code verrat *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _boarCodeCtrl,
                  decoration: _dec('Ex: V-008'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code verrat requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Lot de semence *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _semenLotCtrl,
                  decoration: _dec('Ex: LOT-2026-03A'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Lot requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Date dose 1 *'),
                const SizedBox(height: AppSpacing.s4),
                _datePicker(
                  date: _dose1Date,
                  hint: 'Sélectionner',
                  onTap: () => _pickDate(isDose1: true),
                  fmt: fmt,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Date dose 2'),
                const SizedBox(height: AppSpacing.s4),
                _datePicker(
                  date: _dose2Date,
                  hint: 'Optionnel',
                  onTap: () => _pickDate(isDose1: false),
                  fmt: fmt,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Inséminateur *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _inseminatorCtrl,
                  decoration: _dec('Ex: Paul I.'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Inséminateur requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Statut'),
                const SizedBox(height: AppSpacing.s4),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: _dec(null),
                  items: _statuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _status = v); },
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
