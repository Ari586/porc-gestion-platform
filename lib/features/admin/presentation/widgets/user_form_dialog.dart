import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/utils/password_utils.dart';
import '../../../../theme/app_colors.dart';

/// Dialog for creating or editing a user.
///
/// Pass an existing [user] to open in edit mode; omit it for create mode.
class UserFormDialog extends StatefulWidget {
  final UserProfile? user;

  const UserFormDialog({super.key, this.user});

  /// Show the dialog and return the resulting [UserProfile], or `null` if the
  /// user cancelled.
  static Future<UserProfile?> show(BuildContext context, {UserProfile? user}) {
    return showDialog<UserProfile>(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserFormDialog(user: user),
    );
  }

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _loginCtrl;
  late final TextEditingController _passwordCtrl;
  String _selectedRole = 'Éleveur';
  bool _obscurePassword = true;

  static const _roles = [
    'Admin',
    'Responsable',
    'Éleveur',
    'Inséminateur',
    'Vétérinaire',
    'Technicien labo',
  ];

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _codeCtrl = TextEditingController(text: u?.code ?? '');
    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _contactCtrl = TextEditingController(text: u?.contact ?? '');
    _loginCtrl = TextEditingController(text: u?.login ?? '');
    _passwordCtrl = TextEditingController();
    if (u != null && _roles.contains(u.role)) {
      _selectedRole = u.role;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _loginCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final password = _isEditing
        ? widget.user!.password
        : hashPassword(_passwordCtrl.text.trim());

    final profile = UserProfile(
      id: widget.user?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      code: _codeCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      role: _selectedRole,
      avatar: _nameCtrl.text.trim().isNotEmpty
          ? _nameCtrl.text.trim()[0].toUpperCase()
          : '?',
      contact: _contactCtrl.text.trim(),
      login: _loginCtrl.text.trim(),
      password: password,
    );

    Navigator.of(context).pop(profile);
  }

  @override
  Widget build(BuildContext context) {
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
                      _isEditing ? LucideIcons.edit3 : LucideIcons.userPlus,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: AppSpacing.s10),
                    Text(
                      _isEditing
                          ? 'Modifier l\'utilisateur'
                          : 'Nouvel utilisateur',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                  hint: 'Ex: USR-042',
                  icon: LucideIcons.hash,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code requis' : null,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Name
                _buildField(
                  controller: _nameCtrl,
                  label: 'Nom complet',
                  hint: 'Ex: Jean Razafy',
                  icon: LucideIcons.user,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Role dropdown
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: const Icon(LucideIcons.shield, size: 18),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppUiTokens.detailRowRadius),
                    ),
                  ),
                  items: _roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedRole = v);
                  },
                ),
                const SizedBox(height: AppSpacing.s12),

                // Contact
                _buildField(
                  controller: _contactCtrl,
                  label: 'Contact',
                  hint: 'Ex: +261 34 00 000 00',
                  icon: LucideIcons.phone,
                ),
                const SizedBox(height: AppSpacing.s12),

                // Login
                _buildField(
                  controller: _loginCtrl,
                  label: 'Identifiant',
                  hint: 'Ex: jean.razafy',
                  icon: LucideIcons.atSign,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Identifiant requis'
                      : null,
                ),

                // Password (create mode only)
                if (!_isEditing) ...[
                  const SizedBox(height: AppSpacing.s12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
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
                ],

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
                      label:
                          Text(_isEditing ? 'Enregistrer' : 'Créer'),
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
