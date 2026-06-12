/// Web/desktop stub — no in-app purchases available here.
class PurchaseService {
  bool get available => false;

  Future<void> init(void Function(bool isPremium) onEntitlement) async {}

  Future<void> identify(String? uid) async {}

  Future<String?> priceString() async => null;

  Future<bool> purchase() async => false;

  Future<bool> restore() async => false;
}
