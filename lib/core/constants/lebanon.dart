/// Lebanese-market reference data.
abstract class Lebanon {
  /// Cities & areas used in the profile and (future) garage directory.
  static const List<String> cities = [
    'Beirut',
    'Mount Lebanon',
    'Jounieh',
    'Saida',
    'Tyre',
    'Nabatieh',
    'Tripoli',
    'Zahle',
    'Baalbek',
    'Byblos',
    'Aley',
    'Batroun',
  ];

  /// The Lebanese fleet is a mix of these markets — used to group makes.
  static const List<String> vehicleMarkets = [
    'Japanese',
    'Korean',
    'European',
    'American',
    'Chinese',
  ];
}

/// Supported currencies. Lebanon operates dual-currency (USD "fresh" + LBP).
enum Currency { usd, lbp }

extension CurrencyX on Currency {
  String get code => switch (this) {
        Currency.usd => 'USD',
        Currency.lbp => 'LBP',
      };

  String get symbol => switch (this) {
        Currency.usd => '\$',
        Currency.lbp => 'L.L.',
      };
}
