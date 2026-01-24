import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/order_success_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _notesController = TextEditingController();
  int? _selectedAddressId;
  bool _isLoading = false;

  // Dummy addresses for demo - in real app, load from AddressBloc
  final List<Map<String, dynamic>> _addresses = [
    {
      'id': 1,
      'title': 'المنزل',
      'address': 'شارع الملك فهد، حي النخيل، الرياض',
      'isDefault': true,
    },
    {
      'id': 2,
      'title': 'العمل',
      'address': 'برج الفيصلية، طريق الملك فهد، الرياض',
      'isDefault': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Select default address
    final defaultAddress = _addresses.firstWhere(
      (a) => a['isDefault'] == true,
      orElse: () => _addresses.first,
    );
    _selectedAddressId = defaultAddress['id'];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => OrdersBloc(),
      child: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            // Place the order immediately after creation
            context.read<OrdersBloc>().add(
              OrderPlaceRequested(orderId: state.order.id),
            );
          } else if (state is OrderPlaced) {
            // Clear cart and navigate to success
            context.read<CartBloc>().add(const CartReset());
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(order: state.order),
              ),
              (route) => route.isFirst,
            );
          } else if (state is OrderCreateError) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(context, state.message);
          } else if (state is OrderPlaceError) {
            setState(() => _isLoading = false);
            _showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: ColorsCustom.background,
            appBar: _buildAppBar(context, l10n),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address Section
                  _buildSectionTitle(l10n.deliveryAddress),
                  _buildAddressSection(context, l10n),

                  // Payment Method Section
                  _buildSectionTitle(l10n.paymentMethod),
                  _buildPaymentSection(context, l10n),

                  // Order Notes Section
                  _buildSectionTitle(l10n.orderNotes),
                  _buildNotesSection(context, l10n),

                  // Order Summary Section
                  _buildSectionTitle(l10n.orderSummary),
                  _buildOrderSummary(context, l10n),

                  const SizedBox(height: 120),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(context, l10n, state),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorsCustom.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: ColorsCustom.textPrimary,
          ),
        ),
      ),
      title: TextCustom(
        text: l10n.checkout,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: TextCustom(
        text: title,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _addresses.map((address) {
          final isSelected = _selectedAddressId == address['id'];
          return InkWell(
            onTap: () => setState(() => _selectedAddressId = address['id']),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: address != _addresses.last
                      ? BorderSide(color: ColorsCustom.grey200)
                      : BorderSide.none,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorsCustom.primary.withOpacity(0.1)
                          : ColorsCustom.grey100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      address['title'] == 'المنزل'
                          ? Icons.home_rounded
                          : Icons.work_rounded,
                      color: isSelected
                          ? ColorsCustom.primary
                          : ColorsCustom.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            TextCustom(
                              text: address['title'],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ColorsCustom.textPrimary,
                            ),
                            if (address['isDefault']) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ColorsCustom.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextCustom(
                                  text: l10n.defaultAddress,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: ColorsCustom.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        TextCustom(
                          text: address['address'],
                          fontSize: 13,
                          color: ColorsCustom.textSecondary,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? ColorsCustom.primary
                            : ColorsCustom.grey300,
                        width: 2,
                      ),
                      color: isSelected ? ColorsCustom.primary : Colors.white,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.payments_rounded, color: Colors.green.shade600),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.cashOnDelivery,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: l10n.payWhenReceive,
                  fontSize: 13,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorsCustom.primary,
            ),
            child: const Icon(Icons.check, size: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: l10n.addOrderNotes,
          hintStyle: TextStyle(color: ColorsCustom.textSecondary, fontSize: 14),
          filled: true,
          fillColor: ColorsCustom.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, AppLocalizations l10n) {
    final cart = widget.cart;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Items
          ...cart.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: ColorsCustom.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: item.product.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              item.product.image!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.fastfood_rounded,
                                color: ColorsCustom.grey400,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.fastfood_rounded,
                            color: ColorsCustom.grey400,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextCustom(
                          text: item.product.name,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorsCustom.textPrimary,
                          maxLines: 1,
                        ),
                        TextCustom(
                          text: '${l10n.quantity}: ${item.quantity}',
                          fontSize: 12,
                          color: ColorsCustom.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  TextCustom(
                    text:
                        '${item.totalPriceDouble.toStringAsFixed(2)} ${l10n.currency}',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          Container(height: 1, color: ColorsCustom.grey200),
          const SizedBox(height: 16),

          // Price breakdown
          _buildSummaryRow(l10n.subtotal, cart.subtotalDouble, l10n),
          const SizedBox(height: 8),
          _buildSummaryRow(l10n.deliveryFee, cart.deliveryFeeDouble, l10n),
          if (cart.discountAmountDouble > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              l10n.discount,
              -cart.discountAmountDouble,
              l10n,
              isDiscount: true,
            ),
          ],

          const SizedBox(height: 16),
          Container(height: 1, color: ColorsCustom.grey200),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                text: l10n.total,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
              TextCustom(
                text: '${cart.totalDouble.toStringAsFixed(2)} ${l10n.currency}',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    AppLocalizations l10n, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: label,
          fontSize: 14,
          color: ColorsCustom.textSecondary,
        ),
        TextCustom(
          text:
              '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(2)} ${l10n.currency}',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDiscount ? Colors.green.shade600 : ColorsCustom.textPrimary,
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations l10n,
    OrdersState state,
  ) {
    final isCreating = state is OrderCreating || state is OrderPlacing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ColorsCustom.primary,
                ColorsCustom.primary.withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: ColorsCustom.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isCreating || _isLoading
                  ? null
                  : () => _placeOrder(context),
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: isCreating || _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          TextCustom(
                            text: l10n.confirmOrder,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _placeOrder(BuildContext context) {
    if (_selectedAddressId == null) {
      final l10n = AppLocalizations.of(context)!;
      _showErrorSnackBar(context, l10n.selectAddress);
      return;
    }

    setState(() => _isLoading = true);

    context.read<OrdersBloc>().add(
      OrderCreateRequested(
        deliveryAddressId: _selectedAddressId!,
        paymentMethod: 'cash',
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
