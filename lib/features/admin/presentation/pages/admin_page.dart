import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/stat_mini_card.dart';

class _UserAccount {
  final String id;
  final String name;
  final String role;
  final String email;
  final bool isActive;
  final DateTime lastLogin;

  const _UserAccount({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.isActive = true,
    required this.lastLogin,
  });
}

class _AuditEntry {
  final DateTime timestamp;
  final String actorName;
  final String module;
  final String action;
  final String detail;
  final String severity;

  const _AuditEntry({
    required this.timestamp,
    required this.actorName,
    required this.module,
    required this.action,
    required this.detail,
    this.severity = 'info',
  });
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _activeTab = 'users';
  final _df = DateFormat('dd/MM/yyyy HH:mm');

  final _users = <_UserAccount>[
    _UserAccount(id: '1', name: 'Jean Razafy', role: 'Responsable', email: 'jean@pigia.mg', lastLogin: DateTime(2026, 4, 1, 8, 0)),
    _UserAccount(id: '2', name: 'Dr Rakoto', role: 'Vétérinaire', email: 'rakoto@pigia.mg', lastLogin: DateTime(2026, 4, 1, 7, 45)),
    _UserAccount(id: '3', name: 'Paul Andria', role: 'Inséminateur', email: 'paul@pigia.mg', lastLogin: DateTime(2026, 3, 31, 16, 30)),
    _UserAccount(id: '4', name: 'Marie Rabe', role: 'Éleveur', email: 'marie@pigia.mg', lastLogin: DateTime(2026, 3, 30, 9, 15)),
    _UserAccount(id: '5', name: 'Luc Hery', role: 'Technicien labo', email: 'luc@pigia.mg', isActive: false, lastLogin: DateTime(2026, 3, 15, 14, 0)),
  ];

  final _auditLog = <_AuditEntry>[
    _AuditEntry(timestamp: DateTime(2026, 4, 1, 9, 12), actorName: 'Jean Razafy', module: 'Insémination', action: 'Ajout', detail: 'IA-2026-048 créée (T-003 × V-001)', severity: 'info'),
    _AuditEntry(timestamp: DateTime(2026, 4, 1, 8, 45), actorName: 'Dr Rakoto', module: 'Santé', action: 'Ajout', detail: 'Vaccination Parvo sur T-001, T-002', severity: 'info'),
    _AuditEntry(timestamp: DateTime(2026, 4, 1, 8, 30), actorName: 'Paul Andria', module: 'Verrats', action: 'Modification', detail: 'Qualité spermatique V-002 mise à jour', severity: 'warning'),
    _AuditEntry(timestamp: DateTime(2026, 3, 31, 17, 0), actorName: 'Jean Razafy', module: 'Commercial', action: 'Vente', detail: '6 engraissés vendus — 3 600 000 Ar', severity: 'info'),
    _AuditEntry(timestamp: DateTime(2026, 3, 31, 16, 15), actorName: 'Marie Rabe', module: 'Élevage', action: 'Pesée', detail: 'Bande 2025-10 : 78.2 kg moy, GMQ 820 g/j', severity: 'info'),
    _AuditEntry(timestamp: DateTime(2026, 3, 31, 10, 0), actorName: 'Système', module: 'Sync', action: 'Erreur', detail: 'Échec synchronisation — timeout réseau', severity: 'error'),
    _AuditEntry(timestamp: DateTime(2026, 3, 30, 14, 30), actorName: 'Luc Hery', module: 'Utilisateurs', action: 'Désactivation', detail: 'Compte luc@pigia.mg désactivé', severity: 'warning'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildSummaryStats(),
                  const SizedBox(height: AppSpacing.s14),
                  _buildTabChips(),
                  const SizedBox(height: AppSpacing.s16),
                  if (_activeTab == 'users') _buildUsersSection(),
                  if (_activeTab == 'audit') _buildAuditSection(),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Administration', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('Utilisateurs et journal d\'audit', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.userPlus, size: 16),
          label: const Text('Inviter'),
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    final activeUsers = _users.where((u) => u.isActive).length;
    final roles = _users.map((u) => u.role).toSet().length;
    final todayActions = _auditLog.where((e) => e.timestamp.day == DateTime.now().day).length;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            StatMiniCard(label: 'Utilisateurs', value: '${_users.length}', icon: LucideIcons.users, iconColor: AppColors.primary),
            StatMiniCard(label: 'Actifs', value: '$activeUsers', icon: LucideIcons.userCheck, iconColor: AppColors.success),
            StatMiniCard(label: 'Rôles', value: '$roles', icon: LucideIcons.shield, iconColor: AppColors.info),
            StatMiniCard(label: 'Actions (24h)', value: '$todayActions', icon: LucideIcons.activity, iconColor: AppColors.warning),
          ],
        );
      },
    );
  }

  Widget _buildTabChips() {
    final tabs = {'users': 'Utilisateurs', 'audit': 'Journal d\'audit'};
    return Wrap(
      spacing: 8,
      children: tabs.entries.map((e) => ChoiceChip(
        label: Text(e.value),
        selected: _activeTab == e.key,
        selectedColor: AppColors.primaryPale,
        onSelected: (_) => setState(() => _activeTab = e.key),
      )).toList(),
    );
  }

  Widget _buildUsersSection() {
    return SectionCard(
      title: 'Utilisateurs',
      subtitle: '${_users.length} compte(s)',
      child: Column(
        children: _users.map((u) {
          final roleColor = u.role == 'Responsable' ? AppColors.primary
              : u.role == 'Vétérinaire' ? AppColors.error
              : u.role == 'Inséminateur' ? AppColors.info
              : u.role == 'Technicien labo' ? AppColors.warning
              : AppColors.success;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
              border: Border.all(color: u.isActive ? AppColors.borderLight : AppColors.error.withAlpha(40)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: roleColor.withAlpha(20),
                  child: Text(u.name.split(' ').map((w) => w[0]).take(2).join(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: roleColor)),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(u.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: u.isActive ? AppColors.textPrimary : AppColors.textMuted)),
                      if (!u.isActive) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: AppColors.error.withAlpha(20), borderRadius: BorderRadius.circular(999)),
                          child: const Text('Inactif', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.error)),
                        ),
                      ],
                    ]),
                    Text('${u.role} • ${u.email}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    Text('Dernière connexion : ${_df.format(u.lastLogin)}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                )),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: roleColor.withAlpha(20), borderRadius: BorderRadius.circular(999)),
                  child: Text(u.role, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: roleColor)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuditSection() {
    return SectionCard(
      title: 'Journal d\'audit',
      subtitle: '${_auditLog.length} entrée(s) récentes',
      child: Column(
        children: _auditLog.map((e) {
          final color = e.severity == 'error' ? AppColors.error : e.severity == 'warning' ? AppColors.warning : AppColors.info;
          final icon = e.severity == 'error' ? LucideIcons.alertCircle : e.severity == 'warning' ? LucideIcons.alertTriangle : LucideIcons.checkCircle;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: AppSpacing.s10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(e.actorName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(999)),
                        child: Text(e.module, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(999)),
                        child: Text(e.action, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(e.detail, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  ],
                )),
                Text(_df.format(e.timestamp), style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
