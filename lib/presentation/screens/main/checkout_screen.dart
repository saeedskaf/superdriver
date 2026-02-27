import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:superdriver/domain/bloc/cart/cart_bloc.dart';
import 'package:superdriver/domain/bloc/orders/orders_bloc.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/models/cart_model.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/main/order_success_screen.dart';
import 'package:superdriver/presentation/screens/main/home/home_widgets.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ============================================
// DELIVERY TIME OPTIONS
// ============================================

enum DeliveryTimeOption { now, scheduled }

// ============================================
// CHECKOUT SCREEN
// ============================================

class CheckoutScreen extends StatefulWidget {
  final Cart cart;

  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Map<int, TextEditingController> _itemNotesControllers = {};
  final Map<int, FocusNode> _itemNotesFocusNodes = {};
  final _phoneController = TextEditingController();
  final _phoneNode = FocusNode();

  int? _selectedAddressId;
  List<AddressSummary> _addresses = [];
  bool _isLoadingAddresses = true;
  bool _isLoadingProfile = true;
  bool _phonePreFilled = false;

  DeliveryTimeOption _selectedDeliveryTime = DeliveryTimeOption.now;
  DateTime? _scheduledTime;

  @override
  void initState() {
    super.initState();
    _initItemNotesControllers();
    _loadInitialData();
  }

  void _initItemNotesControllers() {
    for (int i = 0; i < widget.cart.items.length; i++) {
      _itemNotesControllers[i] = TextEditingController();
      _itemNotesFocusNodes[i] = FocusNode();
    }
  }

  void _loadInitialData() {
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
    context.read<AddressBloc>().add(const AddressListRequested());
  }

  @override
  void dispose() {
    for (final c in _itemNotesControllers.values) {
      c.dispose();
    }
    for (final f in _itemNotesFocusNodes.values) {
      f.dispose();
    }
    _phoneController.dispose();
    _phoneNode.dispose();
    super.dispose();
  }

  // ============================================
  // PHONE HELPERS
  // ============================================

  String _normalizePhone(String phone) {
    if (phone.isEmpty) return '';
    var cleaned = phone.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleaned.startsWith('+963')) {
      cleaned = '0${cleaned.substring(4)}';
    } else if (cleaned.startsWith('00963')) {
      cleaned = '0${cleaned.substring(5)}';
    } else if (!cleaned.startsWith('0') && cleaned.length == 9) {
      cleaned = '0$cleaned';
    }
    return cleaned;
  }

  String _formatPhoneForApi(String phone) {
    final normalized = _normalizePhone(phone);
    if (normalized.startsWith('0')) {
      return '+963${normalized.substring(1)}';
    }
    return '+963$normalized';
  }

  // ============================================
  // DATE TIME HELPERS
  // ============================================

  String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (date == DateTime(now.year, now.month, now.day)) {
      dateStr = l10n.today;
    } else if (date == tomorrow) {
      dateStr = l10n.tomorrow;
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? l10n.pm : l10n.am;

    return '$dateStr، $hour:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledTime ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: ColorsCustom.primary),
        ),
        child: child!,
      ),
    );

    if (selectedDate != null && context.mounted) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _scheduledTime ?? now.add(const Duration(hours: 1)),
        ),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: ColorsCustom.primary),
          ),
          child: child!,
        ),
      );

      if (selectedTime != null) {
        setState(() {
          _scheduledTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    }
  }

  // ============================================
  // ORDER CONFIRMATION
  // ============================================

  void _confirmOrder(BuildContext context, AppLocalizations l10n) {
    FocusScope.of(context).unfocus();

    if (_selectedAddressId == null) {
      _showSnackBar(context, l10n.selectAddress, isError: true);
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnackBar(context, l10n.pleaseEnterPhone, isError: true);
      return;
    }

    if (phone.length < 10) {
      _showSnackBar(context, l10n.invalidPhoneNumber, isError: true);
      return;
    }

    if (_selectedDeliveryTime == DeliveryTimeOption.scheduled &&
        _scheduledTime == null) {
      _showSnackBar(context, l10n.pleaseSelectDeliveryTime, isError: true);
      return;
    }

    context.read<OrdersBloc>().add(
      OrderCreateRequested(
        cartId: widget.cart.id,
        deliveryAddressId: _selectedAddressId!,
        paymentMethod: 'cash',
        contactPhone: _formatPhoneForApi(phone),
        scheduledDeliveryTime:
            _selectedDeliveryTime == DeliveryTimeOption.scheduled
            ? _scheduledTime
            : null,
        notes: _buildMergedNotes(),
      ),
    );
  }

  String? _buildMergedNotes() {
    final parts = <String>[];
    final items = widget.cart.items;

    for (int i = 0; i < items.length; i++) {
      final text = _itemNotesControllers[i]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        parts.add('${items[i].product.name}: $text');
      }
    }

    return parts.isNotEmpty ? parts.join('\n') : null;
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToAddresses(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressesScreen()),
    );
    if (!mounted) return;
    context.read<AddressBloc>().add(const AddressListRequested());
  }

  // ============================================
  // BUILD
  // ============================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MultiBlocListener(
        listeners: [
          _buildProfileListener(),
          _buildAddressListener(),
          _buildOrdersListener(),
        ],
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, orderState) => Scaffold(
            backgroundColor: ColorsCustom.background,
            appBar: _buildAppBar(l10n),
            body: _buildBody(l10n),
            bottomNavigationBar: _ConfirmOrderBar(
              isProcessing:
                  orderState is OrderCreating || orderState is OrderPlacing,
              onConfirm: () => _confirmOrder(context, l10n),
            ),
          ),
        ),
      ),
    );
  }

  BlocListener _buildProfileListener() {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          setState(() => _isLoadingProfile = false);
          if (!_phonePreFilled && state.phoneNumber.isNotEmpty) {
            _phoneController.text = _normalizePhone(state.phoneNumber);
            _phonePreFilled = true;
          }
        } else if (state is ProfileError) {
          setState(() => _isLoadingProfile = false);
        }
      },
    );
  }

  BlocListener _buildAddressListener() {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        if (state is AddressListLoaded) {
          setState(() {
            _addresses = state.addresses;
            _isLoadingAddresses = false;

            if (_addresses.isNotEmpty && _selectedAddressId == null) {
              final currentAddress = _addresses.firstWhere(
                (a) => a.isCurrent,
                orElse: () => _addresses.first,
              );
              _selectedAddressId = currentAddress.id;
            }
          });
        } else if (state is AddressError) {
          setState(() => _isLoadingAddresses = false);
          _showSnackBar(context, state.message, isError: true);
        }
      },
    );
  }

  BlocListener _buildOrdersListener() {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderCreated) {
          context.read<OrdersBloc>().add(
            OrderPlaceRequested(orderId: state.order.id),
          );
        } else if (state is OrderPlaced) {
          context.read<CartBloc>().add(const CartReset());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => OrderSuccessScreen(order: state.order),
            ),
            (route) => route.isFirst,
          );
        } else if (state is OrderCreateError) {
          _showSnackBar(context, state.message, isError: true);
        } else if (state is OrderPlaceError) {
          _showSnackBar(context, state.message, isError: true);
        }
      },
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
      leading: const _BackButton(),
      title: TextCustom(
        text: l10n.checkout,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: l10n.deliveryAddress),
          _AddressSection(
            addresses: _addresses,
            selectedId: _selectedAddressId,
            isLoading: _isLoadingAddresses,
            onSelect: (id) => setState(() => _selectedAddressId = id),
            onManage: () => _navigateToAddresses(context),
          ),

          _SectionTitle(title: l10n.contactNumber),
          _PhoneSection(
            controller: _phoneController,
            focusNode: _phoneNode,
            isLoading: _isLoadingProfile,
            onChanged: () => setState(() {}),
          ),

          _SectionTitle(title: l10n.deliveryTime),
          _DeliveryTimeSection(
            selectedOption: _selectedDeliveryTime,
            scheduledTime: _scheduledTime,
            onOptionChanged: (option) => setState(() {
              _selectedDeliveryTime = option;
              if (option == DeliveryTimeOption.now) _scheduledTime = null;
            }),
            onSelectTime: () => _selectDateTime(context),
            formatDateTime: (dt) => _formatDateTime(dt, l10n),
          ),

          _SectionTitle(title: l10n.paymentMethod),
          const _PaymentSection(),

          _SectionTitle(title: l10n.orderNotes),
          _ItemNotesSection(
            items: widget.cart.items,
            controllers: _itemNotesControllers,
            focusNodes: _itemNotesFocusNodes,
          ),

          _SectionTitle(title: l10n.orderSummary),
          _OrderSummarySection(cart: widget.cart),

          const SizedBox(height: 140),
        ],
      ),
    );
  }
}

// ============================================
// APP BAR WIDGETS
// ============================================

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: ColorsCustom.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: ColorsCustom.primary,
          ),
        ),
      ),
    );
  }
}

// ============================================
// SECTION TITLE
// ============================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: TextCustom(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
    );
  }
}

// ============================================
// ADDRESS SECTION
// ============================================

class _AddressSection extends StatelessWidget {
  final List<AddressSummary> addresses;
  final int? selectedId;
  final bool isLoading;
  final ValueChanged<int> onSelect;
  final VoidCallback onManage;

  const _AddressSection({
    required this.addresses,
    required this.selectedId,
    required this.isLoading,
    required this.onSelect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) return _buildLoadingCard();
    if (addresses.isEmpty) return _buildEmptyCard(l10n);
    return _buildAddressList(l10n);
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: ColorsCustom.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: 28,
              color: ColorsCustom.primary.withAlpha(153),
            ),
          ),
          const SizedBox(height: 12),
          TextCustom(
            text: l10n.noAddressesSaved,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: l10n.addAddressToCheckout,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _AddAddressButton(onTap: onManage),
        ],
      ),
    );
  }

  Widget _buildAddressList(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          ...addresses.asMap().entries.map(
            (entry) => _AddressItem(
              address: entry.value,
              isSelected: selectedId == entry.value.id,
              isLast: entry.key == addresses.length - 1,
              onSelect: () => onSelect(entry.value.id),
            ),
          ),
          _ManageAddressesButton(onTap: onManage),
        ],
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  final AddressSummary address;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onSelect;

  const _AddressItem({
    required this.address,
    required this.isSelected,
    required this.isLast,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: !isLast
              ? const Border(bottom: BorderSide(color: ColorsCustom.border))
              : null,
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(child: _buildInfo(l10n)),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? ColorsCustom.primarySoft : ColorsCustom.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.location_on_rounded,
        color: isSelected ? ColorsCustom.primary : ColorsCustom.textSecondary,
        size: 22,
      ),
    );
  }

  Widget _buildInfo(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: TextCustom(
                text: address.title,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
            ),
            if (address.isCurrent) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ColorsCustom.primarySoft,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TextCustom(
                  text: l10n.defaultAddress,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.primary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        TextCustom(
          text: '${address.governorateName} - ${address.areaName}',
          fontSize: 12,
          color: ColorsCustom.textSecondary,
          maxLines: 1,
        ),
      ],
    );
  }
}

class _AddAddressButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddAddressButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ColorsCustom.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_location_alt_outlined,
              color: ColorsCustom.textOnPrimary,
              size: 20,
            ),
            const SizedBox(width: 8),
            TextCustom(
              text: l10n.addAddress,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textOnPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageAddressesButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageAddressesButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorsCustom.border)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: ColorsCustom.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            TextCustom(
              text: l10n.manageAddresses,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PHONE SECTION
// ============================================

class _PhoneSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onChanged;

  const _PhoneSection({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 14),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.phone_rounded, color: Colors.blue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextCustom(
            text: l10n.phoneContactMessage,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildInput() {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      textDirection: TextDirection.ltr,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: ColorsCustom.textPrimary,
        fontFamily: 'Cairo',
      ),
      onSubmitted: (_) => focusNode.unfocus(),
      onChanged: (_) => onChanged(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: '09XXXXXXXX',
        hintStyle: const TextStyle(
          color: ColorsCustom.textHint,
          fontSize: 18,
          fontWeight: FontWeight.normal,
          letterSpacing: 1.5,
          fontFamily: 'Cairo',
        ),
        filled: true,
        fillColor: ColorsCustom.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: const Padding(
          padding: EdgeInsets.all(14),
          child: Icon(
            Icons.phone_android_rounded,
            color: ColorsCustom.textSecondary,
            size: 24,
          ),
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: ColorsCustom.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged();
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}

// ============================================
// DELIVERY TIME SECTION
// ============================================

class _DeliveryTimeSection extends StatelessWidget {
  final DeliveryTimeOption selectedOption;
  final DateTime? scheduledTime;
  final ValueChanged<DeliveryTimeOption> onOptionChanged;
  final VoidCallback onSelectTime;
  final String Function(DateTime) formatDateTime;

  const _DeliveryTimeSection({
    required this.selectedOption,
    required this.scheduledTime,
    required this.onOptionChanged,
    required this.onSelectTime,
    required this.formatDateTime,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          _DeliveryTimeOption(
            icon: Icons.flash_on_rounded,
            title: l10n.immediateDelivery,
            subtitle: l10n.within30To45Minutes,
            iconColor: Colors.orange,
            isSelected: selectedOption == DeliveryTimeOption.now,
            onTap: () => onOptionChanged(DeliveryTimeOption.now),
          ),
          const Divider(color: ColorsCustom.border, height: 1),
          _DeliveryTimeOption(
            icon: Icons.schedule_rounded,
            title: l10n.scheduleDelivery,
            subtitle: l10n.chooseSpecificTime,
            iconColor: Colors.blue,
            isSelected: selectedOption == DeliveryTimeOption.scheduled,
            onTap: () => onOptionChanged(DeliveryTimeOption.scheduled),
          ),
          if (selectedOption == DeliveryTimeOption.scheduled) ...[
            const Divider(color: ColorsCustom.border, height: 1),
            _ScheduledTimePicker(
              scheduledTime: scheduledTime,
              formatDateTime: formatDateTime,
              onTap: onSelectTime,
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryTimeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTimeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: title,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  TextCustom(
                    text: subtitle,
                    fontSize: 12,
                    color: ColorsCustom.textSecondary,
                  ),
                ],
              ),
            ),
            _SelectionIndicator(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _ScheduledTimePicker extends StatelessWidget {
  final DateTime? scheduledTime;
  final String Function(DateTime) formatDateTime;
  final VoidCallback onTap;

  const _ScheduledTimePicker({
    required this.scheduledTime,
    required this.formatDateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ColorsCustom.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: ColorsCustom.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextCustom(
                  text: scheduledTime == null
                      ? l10n.selectDateAndTime
                      : formatDateTime(scheduledTime!),
                  fontSize: 14,
                  fontWeight: scheduledTime == null
                      ? FontWeight.normal
                      : FontWeight.w600,
                  color: scheduledTime == null
                      ? ColorsCustom.textSecondary
                      : ColorsCustom.textPrimary,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: ColorsCustom.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// PAYMENT SECTION
// ============================================

class _PaymentSection extends StatelessWidget {
  const _PaymentSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: ColorsCustom.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: ColorsCustom.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.cashOnDelivery,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 2),
                TextCustom(
                  text: l10n.payWhenReceive,
                  fontSize: 12,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
          const _SelectionIndicator(isSelected: true),
        ],
      ),
    );
  }
}

// ============================================
// ITEM NOTES SECTION
// ============================================

class _ItemNotesSection extends StatelessWidget {
  final List<CartItem> items;
  final Map<int, TextEditingController> controllers;
  final Map<int, FocusNode> focusNodes;

  const _ItemNotesSection({
    required this.items,
    required this.controllers,
    required this.focusNodes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            _ItemNoteField(
              itemName: items[i].product.name,
              quantity: items[i].quantity,
              controller: controllers[i]!,
              focusNode: focusNodes[i]!,
              hintText: '${l10n.addOrderNotes}...',
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemNoteField extends StatelessWidget {
  final String itemName;
  final int quantity;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;

  const _ItemNoteField({
    required this.itemName,
    required this.quantity,
    required this.controller,
    required this.focusNode,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: ColorsCustom.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextCustom(
                text: '$itemName  x$quantity',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ColorsCustom.textPrimary,
                maxLines: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 2,
          minLines: 1,
          maxLength: 150,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => focusNode.unfocus(),
          style: const TextStyle(
            fontSize: 13,
            color: ColorsCustom.textPrimary,
            fontFamily: 'Cairo',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: ColorsCustom.textHint,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
            filled: true,
            fillColor: ColorsCustom.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

// ============================================
// ORDER SUMMARY SECTION
// ============================================

class _OrderSummarySection extends StatelessWidget {
  final Cart cart;

  const _OrderSummarySection({required this.cart});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          _buildCartItems(l10n),
          const SizedBox(height: 6),
          const Divider(color: ColorsCustom.border, height: 1),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.subtotal, amount: cart.subtotalDouble),
          const SizedBox(height: 8),
          _SummaryRow(label: l10n.deliveryFee, amount: cart.deliveryFeeDouble),
          if (cart.discountAmountDouble > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.discount,
              amount: -cart.discountAmountDouble,
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: ColorsCustom.border, height: 1),
          const SizedBox(height: 12),
          _TotalRow(total: cart.totalDouble),
        ],
      ),
    );
  }

  Widget _buildCartItems(AppLocalizations l10n) {
    return Column(
      children: [
        ...cart.items.take(3).map((item) => _CartItemRow(item: item)),
        if (cart.items.length > 3)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: TextCustom(
              text: '+${cart.items.length - 3} ${l10n.otherItems}',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.primary,
            ),
          ),
      ],
    );
  }
}

class _CartItemRow extends StatelessWidget {
  final CartItem item;

  const _CartItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          _buildImage(),
          const SizedBox(width: 10),
          Expanded(child: _buildInfo()),
          TextCustom(
            text:
                '${item.totalPriceDouble.toStringAsFixed(0)} ${l10n.currency}',
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final url = getFullImageUrl(item.product.image);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: url.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.fastfood_rounded,
        color: ColorsCustom.primary,
        size: 20,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          text: item.product.name,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ColorsCustom.textPrimary,
          maxLines: 1,
        ),
        TextCustom(
          text: 'x${item.quantity}',
          fontSize: 11,
          color: ColorsCustom.textSecondary,
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDiscount;

  const _SummaryRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: label,
          fontSize: 13,
          color: ColorsCustom.textSecondary,
        ),
        TextCustom(
          text:
              '${isDiscount ? '-' : ''}${amount.abs().toStringAsFixed(0)} ${l10n.currency}',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDiscount ? ColorsCustom.success : ColorsCustom.textPrimary,
        ),
      ],
    );
  }
}

class _TotalRow extends StatelessWidget {
  final double total;

  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          text: l10n.total,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        TextCustom(
          text: '${total.toStringAsFixed(0)} ${l10n.currency}',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.primary,
        ),
      ],
    );
  }
}

// ============================================
// CONFIRM ORDER BAR
// ============================================

class _ConfirmOrderBar extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onConfirm;

  const _ConfirmOrderBar({required this.isProcessing, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: isProcessing ? null : onConfirm,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: isProcessing
                  ? ColorsCustom.primary.withAlpha(179)
                  : ColorsCustom.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorsCustom.textOnPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: ColorsCustom.textOnPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        TextCustom(
                          text: l10n.confirmOrder,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorsCustom.textOnPrimary,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// SHARED WIDGETS
// ============================================

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? ColorsCustom.primary : ColorsCustom.border,
          width: 2,
        ),
        color: isSelected ? ColorsCustom.primary : ColorsCustom.surface,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 12, color: ColorsCustom.textOnPrimary)
          : null,
    );
  }
}
