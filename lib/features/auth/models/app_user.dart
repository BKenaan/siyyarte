import '../../../core/constants/lebanon.dart';

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phone;
  final String language; // 'en' | 'ar'
  final String? city;
  final Currency preferredCurrency;

  const AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phone,
    this.language = 'en',
    this.city,
    this.preferredCurrency = Currency.usd,
  });

  AppUser copyWith({
    String? name,
    String? language,
    String? city,
    Currency? preferredCurrency,
  }) =>
      AppUser(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone,
        language: language ?? this.language,
        city: city ?? this.city,
        preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      );
}
