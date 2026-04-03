import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../models/boar.dart';
import '../models/sow.dart';
import '../models/insemination_record.dart';
import '../models/health_record.dart';
import '../models/sale_record.dart';

class ExcelExportService {
  static final _df = DateFormat('dd/MM/yyyy');

  // ── Boar list ─────────────────────────────────────────────────────

  static Uint8List exportBoars(List<Boar> boars) {
    final excel = Excel.createExcel();
    final sheet = excel['Verrats'];

    sheet.appendRow([
      TextCellValue('Code'),
      TextCellValue('Nom'),
      TextCellValue('Race'),
      TextCellValue('Date naissance'),
      TextCellValue('Origine'),
      TextCellValue('Type semence'),
      TextCellValue('Motilité (%)'),
      TextCellValue('Volume (ml)'),
      TextCellValue('Force'),
      TextCellValue('SPZ/ml'),
      TextCellValue('Notes'),
    ]);

    for (final b in boars) {
      sheet.appendRow([
        TextCellValue(b.code),
        TextCellValue(b.name),
        TextCellValue(b.breed),
        TextCellValue(_df.format(b.birthDate)),
        TextCellValue(b.origin),
        TextCellValue(b.semenType),
        DoubleCellValue(b.freshMotilityPercent),
        DoubleCellValue(b.freshQuantityMl),
        DoubleCellValue(b.freshForceScore),
        DoubleCellValue(b.freshEstimatedSpzPerMl),
        TextCellValue(b.notes),
      ]);
    }

    // Remove default "Sheet1" if present.
    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Sow list ──────────────────────────────────────────────────────

  static Uint8List exportSows(List<Sow> sows) {
    final excel = Excel.createExcel();
    final sheet = excel['Truies'];

    sheet.appendRow([
      TextCellValue('Code'),
      TextCellValue('Nom'),
      TextCellValue('Race'),
      TextCellValue('Parité'),
      TextCellValue('Date naissance'),
      TextCellValue('Code père'),
      TextCellValue('Code mère'),
      TextCellValue('Notes'),
    ]);

    for (final s in sows) {
      sheet.appendRow([
        TextCellValue(s.code),
        TextCellValue(s.name),
        TextCellValue(s.breed),
        IntCellValue(s.parity),
        TextCellValue(_df.format(s.birthDate)),
        TextCellValue(s.sireCode),
        TextCellValue(s.damCode),
        TextCellValue(s.notes),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Insemination records ──────────────────────────────────────────

  static Uint8List exportInseminations(List<InseminationRecord> records) {
    final excel = Excel.createExcel();
    final sheet = excel['Inséminations'];

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Truie'),
      TextCellValue('Verrat'),
      TextCellValue('Date IA 1'),
      TextCellValue('Date IA 2'),
      TextCellValue('Statut'),
      TextCellValue('Retour prévu'),
      TextCellValue('Retour réel'),
      TextCellValue('Inséminateur'),
      TextCellValue('Notes'),
    ]);

    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r.id),
        TextCellValue(r.sowCode),
        TextCellValue(r.boarCode),
        TextCellValue(_df.format(r.dose1Date)),
        TextCellValue(r.dose2Date != null ? _df.format(r.dose2Date!) : ''),
        TextCellValue(r.status),
        TextCellValue(r.projectedReturnDate != null ? _df.format(r.projectedReturnDate!) : ''),
        TextCellValue(r.actualReturnDate != null ? _df.format(r.actualReturnDate!) : ''),
        TextCellValue(r.inseminator),
        TextCellValue(r.notes),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Health records ────────────────────────────────────────────────

  static Uint8List exportHealthRecords(List<HealthRecord> records) {
    final excel = Excel.createExcel();
    final sheet = excel['Santé'];

    sheet.appendRow([
      TextCellValue('Animal'),
      TextCellValue('Code'),
      TextCellValue('Événement'),
      TextCellValue('Date'),
      TextCellValue('Produit'),
      TextCellValue('Dose'),
      TextCellValue('Raison'),
      TextCellValue('Prochaine date'),
      TextCellValue('Responsable'),
      TextCellValue('Notes'),
    ]);

    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r.animalType),
        TextCellValue(r.animalCode),
        TextCellValue(r.eventType),
        TextCellValue(_df.format(r.eventDate)),
        TextCellValue(r.product),
        TextCellValue(r.dose),
        TextCellValue(r.reason),
        TextCellValue(r.nextDate != null ? _df.format(r.nextDate!) : ''),
        TextCellValue(r.responsible),
        TextCellValue(r.notes),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }

  // ── Sales ─────────────────────────────────────────────────────────

  static Uint8List exportSales(List<SaleRecord> records) {
    final excel = Excel.createExcel();
    final sheet = excel['Ventes'];

    sheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Type'),
      TextCellValue('Client'),
      TextCellValue('Date'),
      TextCellValue('Quantité'),
      TextCellValue('Montant (Ar)'),
    ]);

    for (final r in records) {
      sheet.appendRow([
        TextCellValue(r.id),
        TextCellValue(r.type),
        TextCellValue(r.clientId),
        TextCellValue(_df.format(r.date)),
        IntCellValue(r.quantity),
        DoubleCellValue(r.amount),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) excel.delete('Sheet1');
    return Uint8List.fromList(excel.encode()!);
  }
}
