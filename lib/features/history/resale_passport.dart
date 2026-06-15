import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/lebanon.dart';
import '../../core/models/money.dart';
import '../maintenance/models/service_record.dart';
import '../specs/verified_spec.dart';
import '../vehicles/models/vehicle.dart';

/// A shareable "vehicle passport" — a branded, complete service-history and
/// cost report that documents how well a car has been maintained. In Lebanon's
/// used-car market, a full documented history raises resale value and trust.
abstract class ResalePassportPdf {
  static Future<void> export(Vehicle v, List<ServiceRecord> history,
      {VerifiedSpec? verified}) async {
    final df = DateFormat.yMMMd();

    double usd = 0, lbp = 0;
    for (final r in history) {
      final c = r.cost;
      if (c == null) continue;
      if (c.currency == Currency.usd) {
        usd += c.amount;
      } else {
        lbp += c.amount;
      }
    }
    final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
    final firstDate = sorted.isEmpty ? null : sorted.first.date;
    final lastDate = sorted.isEmpty ? null : sorted.last.date;

    // --- Integrity signals (the resale buyer's trust check) ---
    final evidenceCount = history.where((r) => r.source.hasEvidence).length;
    final scannedCount =
        history.where((r) => r.source == RecordSource.invoiceScan).length;
    // Odometer should not decrease as service dates advance.
    var anomalies = 0;
    var runMax = -1;
    for (final r in sorted) {
      if (runMax >= 0 && r.odometerKm < runMax) anomalies++;
      if (r.odometerKm > runMax) runMax = r.odometerKm;
    }
    // Were all entries logged in one sitting (common with backfilled history)?
    final loggedDays = <String>{
      for (final r in history)
        '${r.createdAt.year}-${r.createdAt.month}-${r.createdAt.day}'
    };
    final allLoggedSameDay = history.length >= 4 && loggedDays.length == 1;

    Uint8List? logo;
    try {
      logo = (await rootBundle.load('assets/brand/siyyarte_mark.png'))
          .buffer
          .asUint8List();
    } catch (_) {}

    final totals = <String>[
      if (usd > 0) Money.usd(usd).formatted(),
      if (lbp > 0) Money.lbp(lbp).formatted(),
    ];

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logo != null)
                pw.Container(
                  width: 46,
                  height: 46,
                  margin: const pw.EdgeInsets.only(right: 12),
                  child: pw.Image(pw.MemoryImage(logo)),
                ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SIYYARTE',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5)),
                  pw.Text('Vehicle Passport — Service & Cost Record',
                      style: const pw.TextStyle(
                          fontSize: 11, color: PdfColors.grey700)),
                ],
              ),
            ],
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),

          // Vehicle summary
          pw.Text(v.displayName,
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Wrap(spacing: 24, runSpacing: 4, children: [
            _kv('Trim', v.trim),
            _kv('Engine', v.engineType),
            _kv('Fuel', v.fuelType),
            _kv('Transmission', v.transmission),
            _kv('Plate', v.plateNumber),
            _kv('VIN', v.vin),
            _kv('Current odometer',
                '${NumberFormat.decimalPattern().format(v.odometerKm)} km'),
          ]),
          pw.SizedBox(height: 16),

          // Usage / cost summary
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _stat('Services recorded', '${history.length}'),
                _stat('Total spent',
                    totals.isEmpty ? '—' : totals.join('  +  ')),
                _stat(
                    'History period',
                    firstDate == null
                        ? '—'
                        : '${df.format(firstDate)} – ${df.format(lastDate!)}'),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Verification / integrity signals
          pw.Text('Verification',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          // Ownership: was the vehicle itself proven real when it was added?
          pw.Bullet(
              text: switch (v.regStatus) {
                RegStatus.verified =>
                  'Ownership: registration card on file — registered holder '
                      '${v.regHolderName ?? '(name on card)'}; the VIN printed '
                      'on the card matches this vehicle\'s VIN (machine-read).',
                RegStatus.cardOnFile => v.regHolderName == null
                    ? 'Ownership: registration card photo on file (VIN on the '
                        'card was not machine-verified).'
                    : 'Ownership: registration card on file — registered '
                        'holder ${v.regHolderName}.',
                RegStatus.mismatch =>
                  'Ownership: WARNING — the VIN on the registration card does '
                      'NOT match the VIN recorded for this vehicle. Verify the '
                      'chassis number in person before purchase.',
                RegStatus.none =>
                  'Ownership: no registration card on file — vehicle identity '
                      'was not verified at entry.',
              },
              style: pw.TextStyle(
                  fontSize: 9,
                  color: switch (v.regStatus) {
                    RegStatus.verified => PdfColors.green800,
                    RegStatus.mismatch => PdfColors.red700,
                    RegStatus.none => PdfColors.orange700,
                    RegStatus.cardOnFile => PdfColors.grey700,
                  })),
          pw.Bullet(
              text:
                  'Documented evidence: $evidenceCount of ${history.length} records '
                  'have an attached invoice photo or AI-scanned receipt '
                  '($scannedCount scanned).',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Bullet(
              text:
                  'Entry log: each record\'s logged-on time is stamped by the '
                  'Siyyarte server and cannot be backdated (tamper-evident).',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Bullet(
              text: anomalies == 0
                  ? 'Odometer consistency: readings increase consistently with dates.'
                  : 'Odometer consistency: $anomalies reading(s) decrease over '
                      'time — verify (possible cluster/odometer change).',
              style: pw.TextStyle(
                  fontSize: 9,
                  color: anomalies == 0 ? PdfColors.grey700 : PdfColors.red700)),
          if (allLoggedSameDay)
            pw.Bullet(
                text:
                    'Note: all records were logged on the same day (backfilled '
                    'history rather than logged over time).',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.orange700)),
          pw.SizedBox(height: 16),

          // --- Manufacturer-verified specifications (cited) ---
          if (verified != null && _verifiedRows(verified).isNotEmpty) ...[
            pw.Text('Manufacturer-verified specifications',
                style:
                    pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 2),
            pw.Text(
                'Official ${verified.marketScope} manufacturer sources — every '
                'value below is cited to its document and page.',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: const pw.FlexColumnWidth(2.2),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FlexColumnWidth(3.5),
              },
              headers: const [
                'Specification',
                'Value',
                'Official source'
              ],
              data: _verifiedRows(verified),
            ),
            pw.SizedBox(height: 16),
          ],

          pw.Text('Complete service history',
              style:
                  pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (sorted.isEmpty)
            pw.Text('No service records.',
                style: const pw.TextStyle(
                    fontSize: 10, color: PdfColors.grey600))
          else
            pw.TableHelper.fromTextArray(
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.centerLeft,
              headers: const [
                'Date',
                'Service',
                'Odometer',
                'Garage',
                'Cost',
                'Evidence'
              ],
              data: sorted
                  .map((r) => [
                        df.format(r.date),
                        r.type.name,
                        NumberFormat.decimalPattern().format(r.odometerKm),
                        r.garageName ?? '-',
                        r.cost?.formatted() ?? '-',
                        switch (r.source) {
                          RecordSource.invoiceScan => 'Scanned',
                          RecordSource.invoicePhoto => 'Invoice',
                          RecordSource.manual =>
                            r.invoiceUrl != null ? 'Invoice' : '—',
                        },
                      ])
                  .toList(),
            ),

          pw.SizedBox(height: 18),
          pw.Divider(color: PdfColors.grey300),
          pw.Text(
            'This passport was generated by Siyyarte from owner-maintained '
            'records. ${history.length} service records, '
            'generated ${df.format(DateTime.now())}. Maintenance intervals '
            'follow manufacturer factory schedules. Cost figures are as '
            'recorded by the owner.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => doc.save());
  }

  /// Flattens the verified spec's cited fluids, attributes and maintenance
  /// intervals into [Specification, Value, Source] rows for the passport table.
  /// Only cited (source + page) values are included — the golden rule.
  static List<List<String>> _verifiedRows(VerifiedSpec s) {
    final rows = <List<String>>[];
    String cite(String? doc, String? page) =>
        [doc, page].where((x) => x != null && x.isNotEmpty).join(', ');

    for (final f in [...s.fluids, ...s.attributes]) {
      if ((f.value ?? '').isEmpty || !f.hasCitation) continue;
      rows.add([f.label, f.value!, cite(f.sourceDoc, f.sourcePage)]);
    }
    for (final iv in s.maintenance) {
      final txt = _intervalText(iv);
      if (txt == null || iv.sourceDoc == null) continue;
      rows.add([iv.item, txt, cite(iv.sourceDoc, iv.sourcePage)]);
    }
    return rows;
  }

  static String? _intervalText(VerifiedInterval v) {
    String km(int k) => '${(k / 1000).toStringAsFixed(0)},000 km';
    if (v.severeKm != null) {
      return 'Severe: every ${km(v.severeKm!)}'
          '${v.severeMonths != null ? ' / ${v.severeMonths} mo' : ''}'
          '${v.normalKm != null ? ' · Normal: ${km(v.normalKm!)}' : ''}';
    }
    if (v.normalKm != null) {
      return 'Every ${km(v.normalKm!)}'
          '${v.normalMonths != null ? ' / ${v.normalMonths} mo' : ''}';
    }
    if (v.firstKm != null) {
      return 'First ${km(v.firstKm!)}'
          '${v.subsequentKm != null ? ', then ${km(v.subsequentKm!)}' : ''}';
    }
    return v.notes;
  }

  static pw.Widget _kv(String k, String? val) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text: '$k: ',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey600)),
              pw.TextSpan(
                  text: (val == null || val.isEmpty) ? '—' : val,
                  style: const pw.TextStyle(fontSize: 10)),
            ],
          ),
        ),
      );

  static pw.Widget _stat(String label, String value) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          pw.SizedBox(height: 2),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
        ],
      );
}
