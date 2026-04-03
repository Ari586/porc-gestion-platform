import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/sow.dart';
import '../../../../theme/app_colors.dart';

class SowFormDialog extends StatefulWidget {
  final Sow? sow;

  const SowFormDialog({super.key, this.sow});

  static Future<Sow?> show(BuildContext context, {Sow? sow}) {
    return showDialog<Sow>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SowFormDialog(sow: sow),
    );
  }

  @override
  State<SowFormDialog> createState() => _SowFormDialogState();
}

class _SowFormDialogState extends State<SowFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _breedCtrl;
  late final TextEditingController _parityCtrl;
  late final TextEditingController _sireCodeCtrl;
  late final TextEditingController _damCodeCtrl;
  late final TextEditingController _notesCtrl;
  DateTime? _birthDate;

  bool get _isEditing => widget.sow != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sow;
    _codeCtrl = TextEditingController(text: s?.code ?? '');
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _breedCtrl = TextEditingController(text: s?.breed ?? '');
    _parityCtrl = TextEditingController(
      text: s != null ? s.parity.toString() : '',
    );
    _sireCodeCtrl = TextEditingController(text: s?.sireCode ?? '');
    _damCodeCtrl = TextEditingController(text: s?.damCode ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _birthDate = s?.birthDate;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _parityCtrl.dispose();
    _sireCodeCtrl.dispose();
    _damCodeCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? now,
      firstDate: DateTime(2010),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez selectionner une date de naissance'),
        ),
      );
      return;
    }

    final sow = Sow(
      id: widget.sow?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      breed: _breedCtrl.text.trim(),
      birthDate: _birthDate!,
      parity: int.tryParse(_parityCtrl.text.trim()) ?? 0,
      sireCode: _sireCodeCtrl.text.trim(),
      damCode: _damCodeCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    Navigator.of(context).pop(sow);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
      ),
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
                // Title
                Row(
                  children: [
                    Icon(
                      _isEditing ? LucideIcons.edit3 : LucideIcons.plusCircle,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Text(
                      _isEditing ? 'Modifier la truie' : 'Ajouter une truie',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),

                // Code
                _buildField(
                  controller: _codeCtrl,
                  label: 'Code',
                  hint: 'Ex: T-042',
                  icon: LucideIcons.hash,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code requis' : null,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Name
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nom',
                  hint: 'Ex: Bella',
                  icon: LucideIcons.piggyBank,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Breed
                _buildField(
                  controller: _breedCtrl,
                  label: 'Race',
                  hint: 'Ex: Large White',
                  icon: LucideIcons.tag,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Race requise' : null,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Birth date
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Date de naissance',
                        hintText: 'Selectionner une date',
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                        suffixIcon: const Icon(LucideIcons.chevronDown,
                            size: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              AppUiTokens.detailRowRadius),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _birthDate != null
                            ? dateFormat.format(_birthDate!)
                            : '',
                      ),
                      validator: (_) =>
                          _birthDate == null ? 'Date requise' : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // Parity
                _buildField(
                  controller: _parityCtrl,
                  label: 'Parite',
                  hint: 'Ex: 3',
                  icon: LucideIcons.repeat,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Parite requise';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) {
                      return 'Doit etre un entier > 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s12),

                // Sire code
                _buildField(
                  controller: _sireCodeCtrl,
                  label: 'Code pere',
                  hint: 'Ex: V-008',
                  icon: LucideIcons.arrowUpRight,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Dam code
                _buildField(
                  controller: _damCodeCtrl,
                  label: 'Code mere',
                  hint: 'Ex: T-021',
                  icon: LucideIcons.arrowDownRight,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Notes
                _buildField(
                  controller: _notesCtrl,
                  label: 'Notes',
                  hint: 'Informations supplementaires...',
                  icon: LucideIcons.fileText,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.s20),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    FilledButton.icon(
                      onPressed: _submit,
                      icon: Icon(
                        _isEditing ? LucideIcons.save : LucideIcons.plus,
                        size: 16,
                      ),
                      label: Text(_isEditing ? 'Enregistrer' : 'Ajouter'),
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
        ),
      ),
    );
  }
}
