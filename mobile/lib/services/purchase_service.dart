// lib/services/purchase_service.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'api_service.dart';
import 'plan_service.dart';

class PurchaseService {
  PurchaseService._internal();

  static final PurchaseService instance = PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Premium yerelde aktif edildiğinde (sunucu doğrulaması sonrası veya mağaza onayı yedek yolu).
  final StreamController<void> _premiumActivatedController =
      StreamController<void>.broadcast();

  Stream<void> get onPremiumActivated => _premiumActivatedController.stream;

  /// Google Play + App Store: aynı abonelik ürün kimliği (aylık plan).
  static const String premiumProductId = 'dlaaylik';

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
        continue;
      }

      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        await _activatePremiumFromPurchase(purchaseDetails);
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

  String _purchaseVerificationPayload(PurchaseDetails purchaseDetails) {
    final server = purchaseDetails.verificationData.serverVerificationData;
    if (server.isNotEmpty) return server;
    return purchaseDetails.verificationData.localVerificationData;
  }

  int? _parseExpiresAtMs(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw != null) return int.tryParse(raw.toString());
    return null;
  }

  /// Mağaza satın alımı onaylandıysa premium aç; sunucu yanıt vermezse yerel yedek.
  Future<void> _activatePremiumFromPurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    if (purchaseDetails.productID != premiumProductId) return;

    final token = _purchaseVerificationPayload(purchaseDetails);
    var serverVerified = false;
    int? expiresAtMs;

    if (token.isNotEmpty) {
      try {
        final result = await ApiService.verifyPurchase(
          purchaseToken: token,
          productId: purchaseDetails.productID,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        if (result['verified'] == true) {
          serverVerified = true;
          expiresAtMs = _parseExpiresAtMs(result['expires_at_ms']);
        } else if (kDebugMode) {
          print('Purchase server verify failed: ${result['reason']}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Purchase verification error: $e');
        }
      }
    }

    if (serverVerified) {
      await PlanService.setPremium(expiresAtMs: expiresAtMs);
    } else {
      // Mağaza satın alımı tamamlandı; backend yapılandırılmamış veya geçici hata.
      final fallbackExpiry = DateTime.now()
          .add(const Duration(days: 32))
          .millisecondsSinceEpoch;
      await PlanService.setPremium(expiresAtMs: fallbackExpiry);
      if (kDebugMode) {
        print(
          'Premium activated locally after store purchase (serverVerified=false).',
        );
      }
    }

    if (!_premiumActivatedController.isClosed) {
      _premiumActivatedController.add(null);
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
    _premiumActivatedController.close();
  }
}
