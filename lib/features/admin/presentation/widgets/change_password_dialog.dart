import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/password_utils.dart';
import '../../../../theme/app_colors.dart';

/// Dialog that lets an admin change a user's password.
///
/// Returns the **hashed** new password on confirm, or `null` on cancel.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  /// Show the dialog and return the hashed password, or `null` if cancelled.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(hashPassword(_passwordCtrl.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUiTokens.entityRadius),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
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
                    const Icon(LucideIcons.keyRound,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: AppSpacing.s10),
                    Text(
                      'Changer le mot de passe',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),

                // New password
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    hintText: 'Min. 8 caractères, lettre + chiffre',
                    prefixIcon: const Icon(LucideIcons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.detailRowRadius),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Mot de passe requis';
                    }
                    if (!isStrongPassword(v.trim())) {
                      return 'Min. 8 caractères avec lettre et chiffre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.s12),

                // Confirm password
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    hintText: 'Retapez le mot de passe',
                    prefixIcon: const Icon(LucideIcons.lock, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? LucideIcons.eyeOff
                            : LucideIcons.eye,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.detailRowRadius),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Confirmation requise';
                    }
                    if (v.trim() != _passwordCtrl.text.trim()) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
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
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Confirmer'),
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
}
