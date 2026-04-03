import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/sale_record.dart';
import '../../../../theme/app_colors.dart';

class SaleRecordFormDialog extends StatefulWidget {
  final SaleRecord? record;

  const SaleRecordFormDialog({super.key, this.record});

  static Future<SaleRecord?> show(
    BuildContext context, {
    SaleRecord? record,
  }) {
    return showDialog<SaleRecord>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SaleRecordFormDialog(record: record),
    );
  }

  @override
  State<SaleRecordFormDialog> createState() => _SaleRecordFormDialogState();
}

class _SaleRecordFormDialogState extends State<SaleRecordFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _clientCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _amountCtrl;

  DateTime? _date;
  String _type = 'Porcelets';

  static const _types = ['Porcelets', 'Engraissés', 'Semence', 'Reproducteurs'];

  bool get _isEditing => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _clientCtrl = TextEditingController(text: r?.clientId ?? '');
    _quantityCtrl =
        TextEditingController(text: r != null ? r.quantity.toString() : '');
    _amountCtrl =
        TextEditingController(text: r != null ? r.amount.toStringAsFixed(0) : '');
    _date = r?.date;
    _type = (r?.type != null && _types.contains(r!.type)) ? r.type : 'Porcelets';
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    _quantityCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Date de vente',
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner la date de vente.')),
      );
      return;
    }

    Navigator.of(context).pop(SaleRecord(
      id: widget.record?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      clientId: _clientCtrl.text.trim(),
      date: _date!,
      quantity: int.tryParse(_quantityCtrl.text.trim()) ?? 0,
      amount: double.tryParse(_amountCtrl.text.trim().replaceAll(' ', '')) ?? 0,
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
                      child: const Icon(LucideIcons.shoppingCart,
                          size: 20, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Text(
                        _isEditing ? 'Modifier la vente' : 'Enregistrer une vente',
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

                _label('Type de vente'),
                const SizedBox(height: AppSpacing.s4),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: _dec(null),
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) { if (v != null) setState(() => _type = v); },
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Client *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _clientCtrl,
                  decoration: _dec('Ex: Rakoto Élevage'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Client requis' : null,
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Date de vente *'),
                const SizedBox(height: AppSpacing.s4),
                InkWell(
                  onTap: _pickDate,
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
                        const Icon(LucideIcons.calendar,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          _date != null ? fmt.format(_date!) : 'Sélectionner',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: _date != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Quantité *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _quantityCtrl,
                  decoration: _dec('Ex: 12'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Quantité requise';
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Quantité invalide';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s14),

                _label('Montant (Ar) *'),
                const SizedBox(height: AppSpacing.s4),
                TextFormField(
                  controller: _amountCtrl,
                  decoration: _dec('Ex: 960000'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Montant requis';
                    final n = double.tryParse(v.trim());
                    if (n == null || n <= 0) return 'Montant invalide';
                    return null;
                  },
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
