import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/sale_record.dart';
import '../../../../core/models/stock_item.dart';
import '../../../../core/models/client.dart';
import '../../../../core/models/supplier.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_mini_card.dart';
import '../widgets/sale_record_form_dialog.dart';
import '../../domain/providers.dart';

class CommercialPage extends ConsumerStatefulWidget {
  const CommercialPage({super.key});

  @override
  ConsumerState<CommercialPage> createState() => _CommercialPageState();
}

class _CommercialPageState extends ConsumerState<CommercialPage> {
  String _activeTab = 'ventes';
  final _df = DateFormat('dd/MM/yyyy');
  final _nf = NumberFormat('#,##0', 'fr_FR');

  Future<void> _addSale() async {
    final result = await SaleRecordFormDialog.show(context);
    if (result != null) {
      await ref.read(commercialRepositoryProvider).addSale(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(commercialDataProvider);
    final sales = ref.watch(salesListProvider);
    final stocks = ref.watch(stockListProvider);
    final clients = ref.watch(clientListProvider);
    final suppliers = ref.watch(supplierListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _activeTab == 'ventes'
          ? FloatingActionButton.extended(
              onPressed: _addSale,
              backgroundColor: AppColors.primary,
              icon: const Icon(LucideIcons.plus, color: Colors.white),
              label: const Text('Vente', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            )
          : null,
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
                  _buildSummaryStats(sales, stocks, clients),
                  const SizedBox(height: AppSpacing.s14),
                  _buildTabChips(),
                  const SizedBox(height: AppSpacing.s16),
                  dataAsync.when(
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                    error: (e, _) => Center(child: Text('Erreur: $e', style: TextStyle(color: AppColors.error))),
                    data: (_) {
                      if (_activeTab == 'ventes') return _buildSalesSection(sales, clients);
                      if (_activeTab == 'stock') return _buildStockSection(stocks);
                      if (_activeTab == 'clients') return _buildClientsSection(clients);
                      return _buildSuppliersSection(suppliers);
                    },
                  ),
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
              Text('Commercial', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.s4),
              Text('Ventes, stock et fournisseurs', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(List<SaleRecord> sales, List<StockItem> stocks, List<Client> clients) {
    final totalSales = sales.fold<double>(0, (s, r) => s + r.amount);
    final stockAlerts = stocks.where((s) => s.quantity <= s.alertThreshold).length;
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth > 700 ? 4 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.8,
          children: [
            StatMiniCard(label: 'Ventes totales', value: '${_nf.format(totalSales)} Ar', icon: LucideIcons.banknote, iconColor: AppColors.success),
            StatMiniCard(label: 'Transactions', value: '${sales.length}', icon: LucideIcons.receipt, iconColor: AppColors.primary),
            StatMiniCard(label: 'Clients', value: '${clients.length}', icon: LucideIcons.users, iconColor: AppColors.info),
            StatMiniCard(label: 'Alertes stock', value: '$stockAlerts', icon: LucideIcons.alertTriangle, iconColor: stockAlerts > 0 ? AppColors.error : AppColors.success),
          ],
        );
      },
    );
  }

  Widget _buildTabChips() {
    final tabs = {'ventes': 'Ventes', 'stock': 'Stock', 'clients': 'Clients', 'fournisseurs': 'Fournisseurs'};
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

  Widget _buildSalesSection(List<SaleRecord> sales, List<Client> clients) {
    if (sales.isEmpty) {
      return EmptyState(
        icon: LucideIcons.receipt,
        message: 'Aucune vente enregistrée.',
        actionLabel: 'Ajouter une vente',
        onAction: _addSale,
      );
    }
    return SectionCard(
      title: 'Ventes récentes',
      subtitle: '${sales.length} transaction(s)',
      child: Column(
        children: sales.map((s) {
          final clientName = clients.where((c) => c.id == s.clientId).firstOrNull?.name ?? s.clientId;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.s8),
            padding: AppUiTokens.entityPadding,
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(AppSpacing.s8), decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.banknote, size: 18, color: AppColors.success)),
              const SizedBox(width: AppSpacing.s12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s.type} — $clientName', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                Text('${_df.format(s.date)} • ${s.quantity} unités', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
              ])),
              Text('${_nf.format(s.amount)} Ar', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.success)),
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStockSection(List<StockItem> stocks) {
    if (stocks.isEmpty) return const EmptyState(icon: LucideIcons.package, message: 'Aucun stock enregistré.');
    return SectionCard(
      title: 'Stock',
      subtitle: '${stocks.length} article(s)',
      child: LayoutBuilder(
        builder: (context, c) {
          final cols = c.maxWidth > 700 ? 2 : 1;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3.0),
            itemCount: stocks.length,
            itemBuilder: (_, i) {
              final s = stocks[i];
              final ratio = s.alertThreshold > 0 ? (s.quantity / (s.alertThreshold * 2)).clamp(0.0, 1.0) : 1.0;
              final isAlert = s.quantity <= s.alertThreshold;
              final color = isAlert ? AppColors.error : AppColors.success;
              return Container(
                padding: AppUiTokens.entityPadding,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: isAlert ? AppColors.error.withAlpha(60) : AppColors.borderLight)),
                child: Row(children: [
                  Icon(isAlert ? LucideIcons.alertTriangle : LucideIcons.package, size: 18, color: color),
                  const SizedBox(width: AppSpacing.s10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    ClipRRect(borderRadius: BorderRadius.circular(999), child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: AppColors.surfaceContainer, valueColor: AlwaysStoppedAnimation(color))),
                  ])),
                  const SizedBox(width: AppSpacing.s10),
                  Text('${s.quantity.toStringAsFixed(0)} ${s.unit}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
                ]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildClientsSection(List<Client> clients) {
    if (clients.isEmpty) return const EmptyState(icon: LucideIcons.users, message: 'Aucun client enregistré.');
    return SectionCard(
      title: 'Clients',
      subtitle: '${clients.length} client(s)',
      child: Column(children: clients.map((c) => _buildContactTile(c.name, c.segment, c.contact, LucideIcons.user, AppColors.primary)).toList()),
    );
  }

  Widget _buildSuppliersSection(List<Supplier> suppliers) {
    if (suppliers.isEmpty) return const EmptyState(icon: LucideIcons.truck, message: 'Aucun fournisseur enregistré.');
    return SectionCard(
      title: 'Fournisseurs',
      subtitle: '${suppliers.length} fournisseur(s)',
      child: Column(children: suppliers.map((s) => _buildContactTile(s.name, s.category, s.contact, LucideIcons.truck, AppColors.info)).toList()),
    );
  }

  Widget _buildContactTile(String name, String tag, String contact, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      padding: AppUiTokens.entityPadding,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppUiTokens.detailRowRadius), border: Border.all(color: AppColors.borderLight)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(AppSpacing.s8), decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: color)),
        const SizedBox(width: AppSpacing.s12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
          Text('$tag • $contact', style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}
