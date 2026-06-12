// Supporter tip jar — entirely optional one-time "coffees" via Play Billing.
//
// Design rules, in order:
//   1. The app stays 100% free. Nothing unlocks. A tip is a thank-you, not a
//      purchase of features — the screen says so explicitly.
//   2. Graceful absence: if the store is unreachable or the products aren't
//      configured in Play Console yet, the screen degrades to a kind
//      "not available right now" — never an error, never a crash.
//   3. Consumables, so someone can tip again on a future milestone.
//
// Play Console setup required before this works in production:
//   In-app products → create supporter_coffee_small / _medium / _large
//   (consumable, suggested R29.99 / R59.99 / R119.99 or store equivalent).
//
// English-only like settings — moves to ARB in the pending l10n pass.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

const _kProductIds = <String>{
  'supporter_coffee_small',
  'supporter_coffee_medium',
  'supporter_coffee_large',
};

class SupporterScreen extends StatefulWidget {
  const SupporterScreen({super.key});

  @override
  State<SupporterScreen> createState() => _SupporterScreenState();
}

enum _StoreState { loading, unavailable, ready, thanks }

class _SupporterScreenState extends State<SupporterScreen> {
  _StoreState _state = _StoreState.loading;
  List<ProductDetails> _products = const [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (_) {
        if (mounted) setState(() => _purchasing = false);
      },
    );
    _loadStore();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStore() async {
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        if (mounted) setState(() => _state = _StoreState.unavailable);
        return;
      }
      final response =
          await InAppPurchase.instance.queryProductDetails(_kProductIds);
      final products = response.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      if (!mounted) return;
      setState(() {
        _products = products;
        _state =
            products.isEmpty ? _StoreState.unavailable : _StoreState.ready;
      });
    } catch (_) {
      if (mounted) setState(() => _state = _StoreState.unavailable);
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('supporter_thanks', true);
          H.heavy();
          if (mounted) {
            setState(() {
              _purchasing = false;
              _state = _StoreState.thanks;
            });
          }
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          if (mounted) setState(() => _purchasing = false);
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<void> _buy(ProductDetails product) async {
    if (_purchasing) return;
    setState(() => _purchasing = true);
    H.selection();
    try {
      await InAppPurchase.instance.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } catch (_) {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 4),
                  Text('Support Journey Forward',
                      style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildIntroCard(),
                  const SizedBox(height: 16),
                  switch (_state) {
                    _StoreState.loading => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    _StoreState.unavailable => _buildUnavailable(),
                    _StoreState.ready => _buildTiers(),
                    _StoreState.thanks => _buildThanks(),
                  },
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.forest50,
                  borderRadius: AppRadius.md,
                ),
                child: Icon(Icons.favorite_rounded,
                    color: AppColors.forest600, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Free. No ads. No data sold. Ever.',
                    style: AppTextStyles.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Journey Forward is built by one person and everything in it is '
            'free, forever. Nothing here unlocks anything — your recovery '
            'tools are already all yours.\n\n'
            'If the app is helping you, a coffee simply says thanks and '
            'keeps it alive: ad-free, account-free, and private.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone600, height: 1.55),
          ),
        ],
      ),
    );
  }

  Widget _buildTiers() {
    const icons = [
      Icons.coffee_outlined,
      Icons.coffee_rounded,
      Icons.coffee_maker_outlined,
    ];
    const labels = ['A coffee', 'A big coffee', 'Coffee for the week'];
    return Column(
      children: [
        for (var i = 0; i < _products.length; i++) ...[
          _TierCard(
            icon: icons[i % icons.length],
            label: labels[i % labels.length],
            price: _products[i].price,
            busy: _purchasing,
            onTap: () => _buy(_products[i]),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Text(
          'One-time, handled securely by Google Play. You can tip again on a '
          'future milestone if you feel like it.',
          textAlign: TextAlign.center,
          style: AppTextStyles.caption.copyWith(color: AppColors.stone400),
        ),
      ],
    );
  }

  Widget _buildUnavailable() {
    return SolidCard(
      child: Column(
        children: [
          Icon(Icons.coffee_outlined, size: 36, color: AppColors.stone300),
          const SizedBox(height: 12),
          Text('The tip jar isn\'t available right now',
              style: AppTextStyles.titleSmall, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'No worries — the best way to support Journey Forward is free: '
            'share it with someone who needs it.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone500, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildThanks() {
    return SolidCard(
      child: Column(
        children: [
          Icon(Icons.volunteer_activism_rounded,
              size: 40, color: AppColors.forest600),
          const SizedBox(height: 12),
          Text('Thank you — truly.',
              style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            'Your support keeps this app free and private for everyone '
            'walking the same road. Onward.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone600, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.icon,
    required this.label,
    required this.price,
    required this.busy,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String price;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      borderRadius: AppRadius.xl,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.softBorder),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.forest600),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.titleSmall),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.forest600,
                borderRadius: AppRadius.pill,
              ),
              child: Text(
                price,
                style: AppTextStyles.labelLarge
                    .copyWith(color: AppColors.onForest),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
