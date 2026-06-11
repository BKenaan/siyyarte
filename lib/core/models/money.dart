import '../constants/lebanon.dart';

/// A monetary amount tagged with its currency. Lebanon is dual-currency, so we
/// never store a bare number — always amount + currency.
class Money {
  final double amount;
  final Currency currency;

  const Money(this.amount, this.currency);

  const Money.usd(this.amount) : currency = Currency.usd;
  const Money.lbp(this.amount) : currency = Currency.lbp;

  Map<String, dynamic> toMap() => {
        'amount': amount,
        'currency': currency.code,
      };

  factory Money.fromMap(Map<String, dynamic> map) => Money(
        (map['amount'] as num).toDouble(),
        map['currency'] == 'LBP' ? Currency.lbp : Currency.usd,
      );

  String formatted() {
    if (currency == Currency.usd) {
      return '\$${amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 2)}';
    }
    // LBP: group thousands, no decimals.
    final whole = amount.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) buf.write(',');
      buf.write(whole[i]);
    }
    return '$buf L.L.';
  }
}
