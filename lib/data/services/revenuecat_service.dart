import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart' as purchases;
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/config.dart';

part 'revenuecat_service.g.dart';

class RevenueCatService {
  static bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;
    if (!Platform.isIOS && !Platform.isAndroid) {
      throw UnsupportedError(
          'RevenueCat is only configured for iOS and Android.');
    }
    if (AppConfig.revenueCatApiKey.isEmpty) {
      throw StateError('Missing REVENUECAT_API_KEY.');
    }

    await purchases.Purchases.configure(
      purchases.PurchasesConfiguration(AppConfig.revenueCatApiKey),
    );
    _configured = true;
  }

  Future<purchases.CustomerInfo> customerInfo() async {
    await configure();
    return purchases.Purchases.getCustomerInfo();
  }

  Future<bool> isPremium() async {
    final info = await customerInfo();
    return _hasPremium(info);
  }

  Future<purchases.Offerings> offerings() async {
    await configure();
    return purchases.Purchases.getOfferings();
  }

  Future<purchases.CustomerInfo> purchasePackage(
    purchases.Package package,
  ) async {
    await configure();
    final result = await purchases.Purchases.purchase(
      purchases.PurchaseParams.package(package),
    );
    return result.customerInfo;
  }

  Future<purchases.CustomerInfo> restorePurchases() async {
    await configure();
    return purchases.Purchases.restorePurchases();
  }

  Future<bool> presentPaywall() async {
    await configure();
    await RevenueCatUI.presentPaywall();
    return isPremium();
  }

  Future<bool> presentPaywallIfNeeded() async {
    await configure();
    await RevenueCatUI.presentPaywallIfNeeded(
      AppConfig.revenueCatEntitlementId,
    );
    return isPremium();
  }

  Future<purchases.CustomerInfo> presentCustomerCenter() async {
    await configure();
    await RevenueCatUI.presentCustomerCenter();
    return purchases.Purchases.getCustomerInfo();
  }

  static bool hasPremium(purchases.CustomerInfo info) {
    return info.entitlements.all[AppConfig.revenueCatEntitlementId]?.isActive ==
        true;
  }

  static bool _hasPremium(purchases.CustomerInfo info) => hasPremium(info);
}

@riverpod
RevenueCatService revenueCatService(RevenueCatServiceRef ref) {
  return RevenueCatService();
}
