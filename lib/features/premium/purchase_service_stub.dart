/// Web/desktop stub — no in-app purchases available here.
class PurchaseService {
  bool get available => false;

  Future<void> init(void Function(bool isPremium) onEntitlement) async {}

  Future<String?> priceString() async => null;

  Future<bool> purchase() async => false;

  Future<bool> restore() async => false;
}
