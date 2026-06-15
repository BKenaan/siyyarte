import '../../../core/models/money.dart';
import 'service_type.dart';

/// How a record's data was produced — drives the trust/evidence level shown on
/// the (paid) vehicle passport.
enum RecordSource {
  /// Typed in by the owner (self-reported).
  manual,

  /// Auto-filled by the AI invoice scanner (read from a photographed receipt).
  invoiceScan,

  /// Owner typed it but attached an invoice/receipt photo as evidence.
  invoicePhoto,
}

extension RecordSourceX on RecordSource {
  /// Whether this record is backed by documentary evidence (not pure self-report).
  bool get hasEvidence => this != RecordSource.manual;

  static RecordSource fromId(String? id) => RecordSource.values.firstWhere(
        (e) => e.name == id,
        orElse: () => RecordSource.manual,
      );
}

/// An immutable, append-only record of a completed service. Feeds the history
/// timeline and PDF export, and drives next-due recalculation.
class ServiceRecord {
  final String id;
  final String vehicleId;
  final ServiceType type;
  final DateTime date;
  final int odometerKm;
  final String? garageName;
  final String? notes;
  final Money? cost;
  final String? invoiceUrl;
  final RecordSource source;

  /// Fuel fill-up fields (only set when type == ServiceType.fuel). [liters] is
  /// the volume added; [fullTank] marks a tank-filled-to-full event, which is
  /// what makes consumption (L/100km) computable between two such fill-ups.
  final double? liters;
  final bool? fullTank;

  /// When the entry was logged. On Firebase this is a server timestamp the
  /// client cannot backdate (enforced by security rules), making the log
  /// tamper-evident.
  final DateTime createdAt;

  const ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    required this.odometerKm,
    this.garageName,
    this.notes,
    this.cost,
    this.invoiceUrl,
    this.source = RecordSource.manual,
    this.liters,
    this.fullTank,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'vehicleId': vehicleId,
        'type': type.id,
        'date': date.toIso8601String(),
        'odometerKm': odometerKm,
        'garageName': garageName,
        'notes': notes,
        'cost': cost?.toMap(),
        'invoiceUrl': invoiceUrl,
        'source': source.name,
        'liters': liters,
        'fullTank': fullTank,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ServiceRecord.fromMap(String id, Map<String, dynamic> m) =>
      ServiceRecord(
        id: id,
        vehicleId: m['vehicleId'] as String,
        type: ServiceTypeX.fromId(m['type'] as String),
        date: DateTime.parse(m['date'] as String),
        odometerKm: m['odometerKm'] as int,
        garageName: m['garageName'] as String?,
        notes: m['notes'] as String?,
        cost: m['cost'] == null
            ? null
            : Money.fromMap(Map<String, dynamic>.from(m['cost'] as Map)),
        invoiceUrl: m['invoiceUrl'] as String?,
        source: RecordSourceX.fromId(m['source'] as String?),
        liters: (m['liters'] as num?)?.toDouble(),
        fullTank: m['fullTank'] as bool?,
        createdAt: _parseTime(m['createdAt']),
      );

  /// Accepts an ISO string (mock/local) or a Firestore Timestamp (server
  /// timestamp). A pending server timestamp reads as null right after a write —
  /// fall back to "now" until the server value resolves.
  static DateTime _parseTime(Object? v) {
    if (v is String) return DateTime.parse(v);
    if (v == null) return DateTime.now();
    try {
      return (v as dynamic).toDate() as DateTime; // Firestore Timestamp
    } catch (_) {
      return DateTime.now();
    }
  }
}
