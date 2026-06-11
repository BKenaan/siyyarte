import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// The catalog of trackable maintenance services.
enum ServiceType {
  oilChange,
  oilFilter,
  airFilter,
  sparkPlugs,
  brakePads,
  tires,
  battery,
  coolant,
  transmissionFluid,
  timingBelt,
  suspension,
  inspection,
  // Non-maintenance operating costs (no schedule — logged manually).
  insurance,
  registration,
  fuel,
  parking,
  otherExpense,
}

/// Operating-cost categories that aren't part of the maintenance schedule.
const kExpenseTypes = [
  ServiceType.fuel,
  ServiceType.insurance,
  ServiceType.registration,
  ServiceType.parking,
  ServiceType.otherExpense,
];

extension ServiceTypeX on ServiceType {
  String get id => name;

  /// Localized display label.
  String label(AppLocalizations t) => switch (this) {
        ServiceType.oilChange => t.serviceOilChange,
        ServiceType.oilFilter => t.serviceOilFilter,
        ServiceType.airFilter => t.serviceAirFilter,
        ServiceType.sparkPlugs => t.serviceSparkPlugs,
        ServiceType.brakePads => t.serviceBrakePads,
        ServiceType.tires => t.serviceTires,
        ServiceType.battery => t.serviceBattery,
        ServiceType.coolant => t.serviceCoolant,
        ServiceType.transmissionFluid => t.serviceTransmissionFluid,
        ServiceType.timingBelt => t.serviceTimingBelt,
        ServiceType.suspension => t.serviceSuspension,
        ServiceType.inspection => t.serviceInspection,
        ServiceType.insurance => t.serviceInsurance,
        ServiceType.registration => t.serviceRegistration,
        ServiceType.fuel => t.serviceFuel,
        ServiceType.parking => t.serviceParking,
        ServiceType.otherExpense => t.serviceOther,
      };

  /// Language-independent icon so drivers recognize services at a glance.
  IconData get icon => switch (this) {
        ServiceType.oilChange => Icons.oil_barrel_outlined,
        ServiceType.oilFilter => Icons.filter_alt_outlined,
        ServiceType.airFilter => Icons.air_outlined,
        ServiceType.sparkPlugs => Icons.electric_bolt_outlined,
        ServiceType.brakePads => Icons.disc_full_outlined,
        ServiceType.tires => Icons.tire_repair_outlined,
        ServiceType.battery => Icons.battery_charging_full_outlined,
        ServiceType.coolant => Icons.ac_unit_outlined,
        ServiceType.transmissionFluid => Icons.settings_outlined,
        ServiceType.timingBelt => Icons.timelapse_outlined,
        ServiceType.suspension => Icons.airline_seat_legroom_extra_outlined,
        ServiceType.inspection => Icons.fact_check_outlined,
        ServiceType.insurance => Icons.shield_outlined,
        ServiceType.registration => Icons.assignment_outlined,
        ServiceType.fuel => Icons.local_gas_station_outlined,
        ServiceType.parking => Icons.local_parking_outlined,
        ServiceType.otherExpense => Icons.receipt_long_outlined,
      };

  static ServiceType fromId(String id) =>
      ServiceType.values.firstWhere((e) => e.name == id,
          // A record with an unknown/renamed type must degrade gracefully —
          // not crash the whole history/dashboard stream.
          orElse: () => ServiceType.otherExpense);
}
