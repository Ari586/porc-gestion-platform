import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

import '../models/boar.dart';
import '../models/sow.dart';
import '../models/insemination_record.dart';
import '../models/health_record.dart';

class PdfExportService {
  static final _df = DateFormat('dd/MM/yyyy');
  static final _nf = NumberFormat('#,##0', 'fr_FR');

  // ── Boar sheet ────────────────────────────────────────────────────

  static Future<void> exportBoarSheet(Boar boar) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 0, text: 'Fiche Verrat — ${boar.code}'),
          pw.SizedBox(height: 8),
          _row('Nom', boar.name),
          _row('Race', boar.breed),
          _row('Date de naissance', _df.format(boar.birthDate)),
          _row('Origine', boar.origin),
          _row('Type de semence', boar.semenType),
          if (boar.sireCode.isNotEmpty) _row('Code père', boar.sireCode),
          if (boar.damCode.isNotEmpty) _row('Code mère', boar.damCode),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Qualité spermatique'),
          _row('Motilité (%)', '${boar.freshMotilityPercent}'),
          _row('Volume (ml)', '${boar.freshQuantityMl}'),
          _row('Force', '${boar.freshForceScore}'),
          _row('SPZ/ml estimés', _nf.format(boar.freshEstimatedSpzPerMl)),
          if (boar.notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Notes'),
            pw.Text(boar.notes),
          ],
          pw.Spacer(),
          pw.Text('Généré le ${_df.format(DateTime.now())} — PigIA', style: const pw.TextStyle(color: PdfColors.grey)),
        ],
      ),
    ));

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // ── Sow sheet ─────────────────────────────────────────────────────

  static Future<void> exportSowSheet(Sow sow) async {
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Header(level: 0, text: 'Fiche Truie — ${sow.code}'),
          pw.SizedBox(height: 8),
          _row('Nom', sow.name),
          _row('Race', sow.breed),
          _row('Parité', '${sow.parity}'),
          _row('Date de naissance', _df.format(sow.birthDate)),
          if (sow.sireCode.isNotEmpty) _row('Code père', sow.sireCode),
          if (sow.damCode.isNotEmpty) _row('Code mère', sow.damCode),
          if (sow.notes.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Header(level: 1, text: 'Notes'),
            pw.Text(sow.notes),
          ],
          pw.Spacer(),
          pw.Text('Généré le ${_df.format(DateTime.now())} — PigIA', style: const pw.TextStyle(color: PdfColors.grey)),
        ],
      ),
    ));

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // ── Insemination report ───────────────────────────────────────────

  static Future<void> exportInseminationReport(List<InseminationRecord> records) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      header: (_) => pw.Header(level: 0, text: 'Rapport d\'insémination — ${_df.format(DateTime.now())}'),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellPadding: const pw.EdgeInsets.all(4),
          headers: ['Code', 'Truie', 'Verrat', 'Date IA', 'Statut', 'Retour prévu'],
          data: records.map((r) => [
            r.id.length > 8 ? r.id.substring(0, 8) : r.id,
            r.sowCode,
            r.boarCode,
            _df.format(r.dose1Date),
            r.status,
            r.projectedReturnDate != null ? _df.format(r.projectedReturnDate!) : '—',
          ]).toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Total: ${records.length} inséminations', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text('Confirmées: ${records.where((r) => r.status == 'Confirmée').length}'),
        pw.Text('Échouées: ${records.where((r) => r.status == 'Échouée').length}'),
        pw.Text('En attente: ${records.where((r) => r.status == 'En attente').length}'),
      ],
      footer: (_) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('PigIA — Gestion Porcine', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9)),
      ),
    ));

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // ── Health report ─────────────────────────────────────────────────

  static Future<void> exportHealthReport(List<HealthRecord> records) async {
    final pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      header: (_) => pw.Header(level: 0, text: 'Bilan sanitaire — ${_df.format(DateTime.now())}'),
      build: (context) => [
        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
          cellPadding: const pw.EdgeInsets.all(4),
          headers: ['Animal', 'Type', 'Événement', 'Date', 'Produit', 'Responsable'],
          data: records.map((r) => [
            '${r.animalType} ${r.animalCode}',
            r.eventType,
            r.reason,
            _df.format(r.eventDate),
            r.product,
            r.responsible,
          ]).toList(),
        ),
        pw.SizedBox(height: 16),
        pw.Text('Total: ${records.length} événements sanitaires', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ],
      footer: (_) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text('PigIA — Gestion Porcine', style: const pw.TextStyle(color: PdfColors.grey, fontSize: 9)),
      ),
    ));

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }

  // ── Helpers ───────────────────────────────────────────────────────

  static pw.Widget _row(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 160, child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Text(value),
        ],
      ),
    );
  }
}
