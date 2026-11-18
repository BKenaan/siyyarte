import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// How serious a catalogued fault is for the driver. Always paired with a
/// label + icon in the UI (never color alone), mirroring the health palette.
enum FaultSeverity { low, medium, high }

extension FaultSeverityX on FaultSeverity {
  /// Severity color — reuses the app's health palette (green/amber/red).
  Color get color => switch (this) {
        FaultSeverity.low => AppColors.healthGood,
        FaultSeverity.medium => AppColors.healthUpcoming,
        FaultSeverity.high => AppColors.healthOverdue,
      };

  String label(AppLocalizations t) => switch (this) {
        FaultSeverity.low => t.commonFaultsSeverityLow,
        FaultSeverity.medium => t.commonFaultsSeverityMedium,
        FaultSeverity.high => t.commonFaultsSeverityHigh,
      };
}

/// The kind of evidence behind a fault — drives the badge wording so the user
/// can tell an official safety recall apart from a reliability reference.
enum FaultSourceType {
  recall, // Official safety recall (NHTSA / manufacturer)
  tsb, // Technical Service Bulletin
  investigation, // Open/closed regulator investigation
  manufacturerCampaign, // Field action / customer-service campaign (non-recall)
  reliabilityReference, // Reputable known-issue / reliability reference
}

extension FaultSourceTypeX on FaultSourceType {
  String label(AppLocalizations t) => switch (this) {
        FaultSourceType.recall => t.commonFaultsSourceTypeRecall,
        FaultSourceType.tsb => t.commonFaultsSourceTypeTsb,
        FaultSourceType.investigation => t.commonFaultsSourceTypeInvestigation,
        FaultSourceType.manufacturerCampaign =>
          t.commonFaultsSourceTypeCampaign,
        FaultSourceType.reliabilityReference =>
          t.commonFaultsSourceTypeReference,
      };

  /// Official (recall/TSB/investigation/manufacturer campaign) vs secondary
  /// reference — used to tint the citation badge.
  bool get isOfficial => this != FaultSourceType.reliabilityReference;
}

/// A required, real citation for a catalogued fault. Mirrors the verified-spec
/// citation pattern (publisher + document + tappable URL). Every [CommonFault]
/// must carry one — a fault without a source is never shown.
class FaultSource {
  final FaultSourceType type;

  /// Who published it, e.g. "NHTSA", "General Motors", "Toyota".
  final String publisher;

  /// The specific document / reference, e.g. "Recall 21V301000",
  /// "TSB #10-06-01-008B", "Theta II recall 17V224".
  final String reference;

  /// Optional canonical link to the source.
  final String? url;

  const FaultSource({
    required this.type,
    required this.publisher,
    required this.reference,
    this.url,
  });

  bool get hasUrl => url != null && url!.startsWith('http');
}

/// A known issue a specific vehicle (make/model/year-range/engine) is prone to.
///
/// This is a curated, source-cited reference dataset — NOT a diagnosis. Each
/// entry is anchored to a real recall, service bulletin, regulator
/// investigation, or reputable reliability reference. Fault prose is kept in
/// English (technical data); only the surrounding UI chrome is localized.
class CommonFault {
  final String id;

  // --- Applicability ---
  final String make;
  final String model;
  final int yearStart;
  final int yearEnd;

  /// Human-readable affected engine/variant, e.g. "2.8L 1GD-FTV turbo-diesel".
  /// Shown to the driver so they can self-verify applicability.
  final String? engine;

  /// Lowercased tokens used to match [engine] against the vehicle's engineType
  /// (e.g. ["2.8", "1gd", "diesel"]). Empty means the fault applies to every
  /// engine of this model.
  final List<String> engineKeywords;

  // --- Content ---
  final FaultSeverity severity;
  final String title;
  final String description;
  final String symptom;

  /// Odometer (km) the issue typically surfaces around, when known.
  final int? typicalMileageKm;

  // --- Citation (required) ---
  final FaultSource source;

  const CommonFault({
    required this.id,
    required this.make,
    required this.model,
    required this.yearStart,
    required this.yearEnd,
    this.engine,
    this.engineKeywords = const [],
    required this.severity,
    required this.title,
    required this.description,
    required this.symptom,
    this.typicalMileageKm,
    required this.source,
  });

  bool coversYear(int year) => year >= yearStart && year <= yearEnd;

  /// Loose, case-insensitive model match so "Land Cruiser Prado" matches a
  /// "Prado" catalogue entry (and vice versa).
  static bool _modelMatches(String catalogModel, String vehicleModel) {
    final a = catalogModel.toLowerCase().trim();
    final b = vehicleModel.toLowerCase().trim();
    if (a.isEmpty || b.isEmpty) return false;
    return a == b || a.contains(b) || b.contains(a);
  }

  /// Soft engine gate: when the fault targets a specific engine AND the user
  /// recorded an engine, only match if a keyword overlaps — so a petrol Hilux
  /// owner isn't shown a diesel-DPF fault. When the user's engine is unknown,
  /// we show the fault (it's clearly labelled with the affected engine).
  bool _engineApplies(String? vehicleEngine) {
    if (engineKeywords.isEmpty) return true;
    final e = vehicleEngine?.toLowerCase().trim();
    if (e == null || e.isEmpty) return true;
    return engineKeywords.any((k) => e.contains(k.toLowerCase()));
  }

  bool matches({
    required String make,
    required String model,
    required int year,
    String? engine,
  }) {
    return this.make.toLowerCase().trim() == make.toLowerCase().trim() &&
        _modelMatches(this.model, model) &&
        coversYear(year) &&
        _engineApplies(engine);
  }
}
