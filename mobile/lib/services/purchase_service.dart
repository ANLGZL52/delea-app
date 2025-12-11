// lib/services/purchase_service.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'plan_service.dart';

class PurchaseService {
  PurchaseService._internal();

  static final PurchaseService instance = PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  static const String premiumProductId = 'delea_premium_monthly';

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  ProductDetails? _premiumProduct;
  ProductDetails? get premiumProduct => _premiumProduct;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Sadece Android + iOS destekli
  bool get _isSupportedPlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> init() async {
    if (_isInitialized) return;

    // Windows / Web / MacOS / Linux için: store yok → init etme
    if (!_isSupportedPlatform) {
      _isAvailable = false;
      _isInitialized = true;
      if (kDebugMode) {
        print('PurchaseService: In-app purchases not supported on this platform.');
      }
      return;
    }

    _isAvailable = await _iap.isAvailable();

    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (Object e) {
        if (kDebugMode) {
          print('Purchase stream error: $e');
        }
      },
    );

    if (_isAvailable) {
      await _loadProducts();
    }

    _isInitialized = true;
  }

  Future<void> _loadProducts() async {
    final response = await _iap.queryProductDetails({premiumProductId});
    if (response.error != null) {
      if (kDebugMode) {
        print('Product query error: ${response.error}');
      }
      return;
    }

    if (response.productDetails.isEmpty) {
      if (kDebugMode) {
        print('No products found for $premiumProductId');
      }
      return;
    }

    _premiumProduct = response.productDetails.first;
  }

  Future<void> buyPremium() async {
    if (!_isSupportedPlatform) {
      if (kDebugMode) {
        print('buyPremium called on unsupported platform.');
      }
      return;
    }

    if (!_isAvailable) {
      if (kDebugMode) {
        print('Store not available.');
      }
      return;
    }

    if (_premiumProduct == null) {
      await _loadProducts();
      if (_premiumProduct == null) {
        if (kDebugMode) {
          print('Premium product not loaded.');
        }
        return;
      }
    }

    final purchaseParam = PurchaseParam(productDetails: _premiumProduct!);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // İstersen pending için UI gösterebilirsin
      } else {
        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // MVP: Sunucu doğrulaması yok, direkt premium açıyoruz
          await PlanService.setPremium();
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          if (kDebugMode) {
            print('Purchase error: ${purchaseDetails.error}');
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> restorePurchases() async {
    if (!_isSupportedPlatform) {
      if (kDebugMode) {
        print('restorePurchases called on unsupported platform.');
      }
      return;
    }
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
