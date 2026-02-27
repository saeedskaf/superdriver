import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/order_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/main/order_details_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class OrderSuccessScreen extends StatefulWidget {
  final Order order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // ── Success icon ──
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: ColorsCustom.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: ColorsCustom.success.withAlpha(77),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: ColorsCustom.textOnPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 36),

              // ── Title + subtitle ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    TextCustom(
                      text: l10n.orderPlacedSuccessfully,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TextCustom(
                      text: l10n.orderConfirmedMessage,
                      fontSize: 15,
                      color: ColorsCustom.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // ── Order info card ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: ColorsCustom.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ColorsCustom.border),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: l10n.orderNumber,
                        value: widget.order.orderNumber,
                        icon: Icons.receipt_long_rounded,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: ColorsCustom.border, height: 1),
                      ),
                      _InfoRow(
                        label: l10n.total,
                        value:
                            '${widget.order.totalDouble.toStringAsFixed(0)} ${l10n.currency}',
                        icon: Icons.payments_rounded,
                        isPrimary: true,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: ColorsCustom.border, height: 1),
                      ),
                      _InfoRow(
                        label: l10n.paymentMethod,
                        value: l10n.cashOnDelivery,
                        icon: Icons.money_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // ── Buttons ──
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    ButtonCustom.primary(
                      text: l10n.trackOrder,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<OrdersBloc>(),
                              child: OrderDetailsScreen(
                                orderId: widget.order.id,
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delivery_dining_rounded,
                        color: ColorsCustom.textOnPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ButtonCustom.secondary(
                      text: l10n.backToHome,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// INFO ROW
// ============================================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPrimary;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? ColorsCustom.primarySoft : ColorsCustom.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isPrimary
                ? ColorsCustom.primary
                : ColorsCustom.textSecondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                text: label,
                fontSize: 13,
                color: ColorsCustom.textSecondary,
              ),
              const SizedBox(height: 2),
              TextCustom(
                text: value,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPrimary
                    ? ColorsCustom.primary
                    : ColorsCustom.textPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
