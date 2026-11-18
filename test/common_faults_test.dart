import 'package:flutter_test/flutter_test.dart';
import 'package:garagi/features/vehicles/data/common_faults_data.dart';

void main() {
  group('CommonFault catalogue', () {
    test('every fault carries a real citation (publisher + reference)', () {
      for (final f in kCommonFaults) {
        expect(f.source.publisher.trim(), isNotEmpty, reason: f.id);
        expect(f.source.reference.trim(), isNotEmpty, reason: f.id);
        // A URL, when present, must be a real http(s) link.
        if (f.source.url != null) {
          expect(f.source.hasUrl, isTrue, reason: f.id);
        }
        expect(f.yearStart, lessThanOrEqualTo(f.yearEnd), reason: f.id);
      }
    });

    test('fault ids are unique', () {
      final ids = kCommonFaults.map((f) => f.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });

  group('commonFaultsFor matching', () {
    test('matches make/model/year within range', () {
      final faults = commonFaultsFor(
          make: 'Nissan', model: 'Altima', year: 2015, engine: null);
      expect(faults.map((f) => f.id), contains('nissan_altima_cvt'));
    });

    test('excludes years outside the range', () {
      final faults = commonFaultsFor(
          make: 'Nissan', model: 'Altima', year: 2022, engine: null);
      expect(faults.map((f) => f.id), isNot(contains('nissan_altima_cvt')));
    });

    test('loose model match: "Land Cruiser Prado" matches "Prado" entry', () {
      final faults = commonFaultsFor(
          make: 'Toyota',
          model: 'Land Cruiser Prado',
          year: 2012,
          engine: '3.0L 1KD-FTV');
      expect(faults.map((f) => f.id), contains('toyota_prado_1kd_pistons'));
    });

    test('engine keyword gate hides diesel DPF fault from a petrol Hilux', () {
      final petrol = commonFaultsFor(
          make: 'Toyota', model: 'Hilux', year: 2018, engine: '2.7L petrol');
      expect(petrol.map((f) => f.id), isNot(contains('toyota_hilux_1gd_dpf')));

      final diesel = commonFaultsFor(
          make: 'Toyota',
          model: 'Hilux',
          year: 2018,
          engine: '2.8L 1GD-FTV diesel');
      expect(diesel.map((f) => f.id), contains('toyota_hilux_1gd_dpf'));
    });

    test('unknown engine still shows the fault (clearly labelled)', () {
      final faults = commonFaultsFor(
          make: 'Toyota', model: 'Hilux', year: 2018, engine: null);
      expect(faults.map((f) => f.id), contains('toyota_hilux_1gd_dpf'));
    });

    test('results are sorted most-severe first', () {
      final faults = commonFaultsFor(
          make: 'Nissan', model: 'Altima', year: 2015, engine: null);
      for (var i = 1; i < faults.length; i++) {
        expect(faults[i - 1].severity.index,
            greaterThanOrEqualTo(faults[i].severity.index));
      }
    });

    test('no match returns empty (clean empty-state path)', () {
      final faults = commonFaultsFor(
          make: 'Fiat', model: 'Panda', year: 2015, engine: null);
      expect(faults, isEmpty);
    });
  });
}
