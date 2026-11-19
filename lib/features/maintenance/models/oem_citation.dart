/// Lightweight citation value object attached to a [ScheduledService] when the
/// interval that produced it came from a SOURCED OEM maintenance schedule
/// (the `oem_schedules_*.dart` research datasets) rather than the generic
/// computed fallback. Kept in `models/` (no dependency on the data files) so the
/// schedule model, engine and UI can all share it without a dependency cycle.
library;

/// Field-level confidence of a sourced OEM interval, aligned with the A–D scale
/// used across the `oem_schedules_*.dart` datasets and the verified-specs system.
enum OemSourceGrade {
  /// Read directly from a manufacturer / official importer maintenance document.
  a,

  /// Official but market/engine-specific, from a footnote, or a faithful
  /// third-party reproduction of the OEM manual.
  b,

  /// Value only positionally implied by the source (confirm before relying).
  c,

  /// Placeholder — not used by the datasets; present so the scale matches.
  d,
}

extension OemSourceGradeX on OemSourceGrade {
  /// Short display letter, e.g. "A".
  String get letter => switch (this) {
        OemSourceGrade.a => 'A',
        OemSourceGrade.b => 'B',
        OemSourceGrade.c => 'C',
        OemSourceGrade.d => 'D',
      };

  /// Map a source-file grade enum (which exposes the same 0..3 ordering) onto
  /// the canonical scale.
  static OemSourceGrade fromIndex(int index) {
    if (index < 0 || index >= OemSourceGrade.values.length) {
      return OemSourceGrade.d;
    }
    return OemSourceGrade.values[index];
  }
}

/// Provenance for a schedule row backed by a sourced OEM interval. Drives the
/// citation badge on the vehicle detail screen.
class OemCitation {
  /// Human-readable source label (publisher + document), URL stripped.
  final String sourceLabel;

  /// Canonical source URL, when the dataset carried one (null for the
  /// short-provenance German/American datasets whose full cite lives in a
  /// companion SOURCES.md).
  final String? sourceUrl;

  final OemSourceGrade grade;

  /// Whether the source interval is a condition-based / flexible-service
  /// baseline (BMW/Mercedes/GM/Ford/Land Rover etc.) rather than a fixed limit.
  final bool conditionBased;

  /// The original OEM service-item label (e.g. "Transmission Fluid").
  final String serviceLabel;

  /// The interval actually applied (severe-preferred for Lebanon).
  final int? intervalKm;
  final int? intervalMonths;

  /// True when the severe-conditions figure was the one applied.
  final bool usedSevere;

  const OemCitation({
    required this.sourceLabel,
    this.sourceUrl,
    required this.grade,
    required this.conditionBased,
    required this.serviceLabel,
    this.intervalKm,
    this.intervalMonths,
    required this.usedSevere,
  });
}
