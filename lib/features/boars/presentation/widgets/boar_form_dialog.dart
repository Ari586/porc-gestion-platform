import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/boar.dart';

class BoarFormDialog extends StatefulWidget {
  final Boar? boar;

  const BoarFormDialog({super.key, this.boar});

  /// Shows the dialog and returns a [Boar] if the user saved, or null if
  /// cancelled.
  static Future<Boar?> show(BuildContext context, {Boar? boar}) {
    return showDialog<Boar>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BoarFormDialog(boar: boar),
    );
  }

  @override
  State<BoarFormDialog> createState() => _BoarFormDialogState();
}

class _BoarFormDialogState extends State<BoarFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _originCtrl;
  late final TextEditingController _sireCodeCtrl;
  late final TextEditingController _damCodeCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _birthDate;
  String _semenType = 'Fraiche';

  static const _semenTypes = ['Fraiche', 'Congelee', 'Preparee'];
  static const _semenLabels = {
    'Fraiche': 'Fraiche',
    'Congelee': 'Congelee',
    'Preparee': 'Preparee',
  };

  bool get _isEditing => widget.boar != null;

  @override
  void initState() {
    super.initState();
    final b = widget.boar;
    _codeCtrl = TextEditingController(text: b?.code ?? '');
    _nameCtrl = TextEditingController(text: b?.name ?? '');
    _breedCtrl = TextEditingController(text: b?.breed ?? '');
    _originCtrl = TextEditingController(text: b?.origin ?? '');
    _sireCodeCtrl = TextEditingController(text: b?.sireCode ?? '');
    _damCodeCtrl = TextEditingController(text: b?.damCode ?? '');
    _notesCtrl = TextEditingController(text: b?.notes ?? '');
    _birthDate = b?.birthDate;
    _semenType = b?.semenType ?? 'Fraiche';
    // Normalise legacy values
    if (!_semenTypes.contains(_semenType)) {
      _semenType = 'Fraiche';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _originCtrl.dispose();
    _sireCodeCtrl.dispose();
    _damCodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner la date de naissance.'),
        ),
      );
      return;
    }

    final boar = Boar(
      id: widget.boar?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim(),
      birthDate: _birthDate!,
      origin: _originCtrl.text.trim(),
      sireCode: _sireCodeCtrl.text.trim(),
      damCode: _damCodeCtrl.text.trim(),
      semenType: _semenType,
      notes: _notesCtrl.text.trim(),
    );

    Navigator.of(context).pop(boar);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPale,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.piggyBank,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Modifier le verrat' : 'Ajouter un verrat',
                        style: textTheme.titleMedium?.copyWith(
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

                // Code
                _buildLabel('Code *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: _inputDecoration('Ex: V-001'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                // Name
                _buildLabel('Nom *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: _inputDecoration('Ex: Hercule'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                // Breed
                _buildLabel('Race *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _breedCtrl,
                  decoration: _inputDecoration('Ex: Large White'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Race requise' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                // Birth date
                _buildLabel('Date de naissance *'),
                const SizedBox(height: AppSpacing.s4),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: AppSpacing.s12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          _birthDate != null
                              ? DateFormat('dd/MM/yyyy').format(_birthDate!)
                              : 'Selectionner une date',
                          style: textTheme.bodyMedium?.copyWith(
                            color: _birthDate != null
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s14),

                // Origin
                _buildLabel('Origine *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _originCtrl,
                  decoration: _inputDecoration('Ex: France'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Origine requise' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                // Sire code
                _buildLabel('Code du pere'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _sireCodeCtrl,
                  decoration: _inputDecoration('Ex: V-P001'),
                ),
                const SizedBox(height: AppSpacing.s14),

                // Dam code
                _buildLabel('Code de la mere'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _damCodeCtrl,
                  decoration: _inputDecoration('Ex: T-M003'),
                ),
                const SizedBox(height: AppSpacing.s14),

                // Semen type
                _buildLabel('Type de semence'),
                const SizedBox(height: AppSpacing.s4),
                DropdownButtonFormField<String>(
                  initialValue: _semenType,
                  decoration: _inputDecoration(null),
                  items: _semenTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(_semenLabels[t] ?? t),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _semenType = v);
                  },
                ),
                const SizedBox(height: AppSpacing.s14),

                // Notes
                _buildLabel('Notes'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: _inputDecoration('Remarques...'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.s24),

                // Actions
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: AppColors.cardSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s10,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
