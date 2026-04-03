import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/providers/session_provider.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../theme/app_colors.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _autoSync = true;
  bool _darkMode = false;
  bool _offlineMode = false;
  String _language = 'Français';
  String _syncInterval = '5 min';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s16),
                  _buildProfileSection(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildNotificationSection(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildSyncSection(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildAppearanceSection(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildDataSection(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildAboutSection(),
                  const SizedBox(height: AppSpacing.s24),
                  _buildLogoutButton(),
                  const SizedBox(height: AppSpacing.s16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Paramètres', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: AppSpacing.s4),
        Text('Configuration de l\'application', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildProfileSection() {
    final user = ref.watch(sessionProvider);
    return SectionCard(
      title: 'Profil',
      child: Container(
        padding: AppUiTokens.entityPadding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF6EF), Color(0xFFFFF0E5)],
          ),
          borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(user?.avatar ?? '?', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
            ),
            const SizedBox(width: AppSpacing.s14),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.name ?? '—', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(user?.role ?? '—', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
                if (user?.contact.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(LucideIcons.mail, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(user!.contact, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ],
            )),
            IconButton(
              icon: const Icon(LucideIcons.edit3, size: 18, color: AppColors.textMuted),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return SectionCard(
      title: 'Notifications',
      child: Column(
        children: [
          _buildSwitchTile('Notifications push', 'Alertes santé, IA, stock', LucideIcons.bell, _notificationsEnabled, (v) => setState(() => _notificationsEnabled = v)),
          _buildSwitchTile('Sons', 'Bip sonore pour les alertes', LucideIcons.volume2, _soundEnabled, (v) => setState(() => _soundEnabled = v)),
        ],
      ),
    );
  }

  Widget _buildSyncSection() {
    return SectionCard(
      title: 'Synchronisation',
      child: Column(
        children: [
          _buildSwitchTile('Sync automatique', 'Synchroniser avec Firestore', LucideIcons.refreshCw, _autoSync, (v) => setState(() => _autoSync = v)),
          _buildDropdownTile('Intervalle de sync', _syncInterval, LucideIcons.clock, ['1 min', '5 min', '15 min', '30 min'], (v) => setState(() => _syncInterval = v)),
          _buildSwitchTile('Mode hors-ligne', 'Travailler sans connexion', LucideIcons.wifiOff, _offlineMode, (v) => setState(() => _offlineMode = v)),
          _buildInfoTile('Dernière sync', '01/04/2026, 09:15', LucideIcons.checkCircle, AppColors.success),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return SectionCard(
      title: 'Apparence',
      child: Column(
        children: [
          _buildSwitchTile('Mode sombre', 'Interface en mode nuit', LucideIcons.moon, _darkMode, (v) => setState(() => _darkMode = v)),
          _buildDropdownTile('Langue', _language, LucideIcons.globe, ['Français', 'Malagasy', 'English'], (v) => setState(() => _language = v)),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return SectionCard(
      title: 'Données',
      child: Column(
        children: [
          _buildActionTile('Exporter en PDF', 'Générer un rapport PDF', LucideIcons.fileText, AppColors.error, () {}),
          _buildActionTile('Exporter en Excel', 'Télécharger les données Excel', LucideIcons.fileSpreadsheet, AppColors.success, () {}),
          _buildActionTile('Sauvegarder', 'Créer une sauvegarde locale', LucideIcons.database, AppColors.info, () {}),
          _buildActionTile('Vider le cache', 'Libérer l\'espace de stockage', LucideIcons.trash2, AppColors.warning, () {}),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return SectionCard(
      title: 'À propos',
      child: Column(
        children: [
          _buildInfoTile('Version', '2.0.0-beta', LucideIcons.info, AppColors.primary),
          _buildInfoTile('Plateforme', 'PigIA — Gestion Porcine', LucideIcons.piggyBank, AppColors.primary),
          _buildActionTile('Conditions d\'utilisation', '', LucideIcons.fileText, AppColors.textMuted, () {}),
          _buildActionTile('Politique de confidentialité', '', LucideIcons.lock, AppColors.textMuted, () {}),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          )),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(String title, String value, IconData icon, List<String> options, ValueChanged<String> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.s12),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary))),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox.shrink(),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
            items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
            onChanged: (v) { if (v != null) onChanged(v); },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s6),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.s12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.s6),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                  if (subtitle.isNotEmpty) Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              )),
              const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => ref.read(sessionProvider.notifier).logout(),
        icon: const Icon(LucideIcons.logOut, size: 16),
        label: const Text('Déconnexion'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius)),
        ),
      ),
    );
  }
}
