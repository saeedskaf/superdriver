import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/data/services/address_service.dart';
import 'package:superdriver/data/services/chat_service.dart';
import 'package:superdriver/domain/bloc/address/address_bloc.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_button.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_conversation_screen.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_support.dart';
import 'package:superdriver/presentation/screens/main/profile/add_edit_address_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class NewOrderChatScreen extends StatefulWidget {
  const NewOrderChatScreen({super.key});

  @override
  State<NewOrderChatScreen> createState() => _NewOrderChatScreenState();
}

class _NewOrderChatScreenState extends State<NewOrderChatScreen> {
  bool _isLoading = true;
  bool _isCreating = false;
  List<AddressSummary> _addresses = const [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final addresses = await addressService.getAllAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (e) {
      log('NewOrderChatScreen: failed to load addresses: $e');
      if (!mounted) return;
      setState(() {
        _error = l10n.chatConversationsLoadError;
        _isLoading = false;
      });
    }
  }

  Future<void> _startOrderConversation(AddressSummary address) async {
    if (_isCreating) return;
    final session = await loadChatSession(context);
    if (session == null) return;

    setState(() => _isCreating = true);
    try {
      final conversation = await chatService.createOrderConversation(
        userId: session.userId,
        userName: session.userName,
        userPhone: session.userPhone,
        address: address,
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ChatConversationScreen(conversationId: conversation.id),
        ),
      );
    } catch (e) {
      log('NewOrderChatScreen: failed to create conversation: $e');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatCreateConversationError),
          backgroundColor: ColorsCustom.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  void _openAddAddress() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => AddressBloc(),
          child: const AddEditAddressScreen(),
        ),
      ),
    ).then((_) => _loadAddresses());
  }

  void _openManageAddresses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddressesScreen()),
    ).then((_) => _loadAddresses());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: AppBar(
        backgroundColor: ColorsCustom.surface,
        elevation: 0,
        leading: Padding(
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
        ),
        title: TextCustom(
          text: l10n.chatNewOrderTitle,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAddresses,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ColorsCustom.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ColorsCustom.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ColorsCustom.secondarySoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        color: ColorsCustom.secondaryDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextCustom(
                            text: l10n.chatNewOrderTitle,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: ColorsCustom.textPrimary,
                          ),
                          const SizedBox(height: 4),
                          TextCustom(
                            text: l10n.chatNewOrderSubtitle,
                            fontSize: 12,
                            color: ColorsCustom.textSecondary,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextCustom(
                      text: l10n.chatSelectAddress,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _openManageAddresses,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsCustom.primarySoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: ColorsCustom.primary.withAlpha(30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.settings_rounded,
                            size: 14,
                            color: ColorsCustom.primary,
                          ),
                          const SizedBox(width: 4),
                          TextCustom(
                            text: l10n.chatManageAddresses,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ColorsCustom.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: ColorsCustom.primary,
                    ),
                  ),
                )
              else if (_error != null)
                _InfoState(
                  title: _error!,
                  body: l10n.chatNoAddressesBody,
                  actionLabel: l10n.chatAddAddress,
                  onAction: _openAddAddress,
                )
              else if (_addresses.isEmpty)
                _InfoState(
                  title: l10n.chatNoAddresses,
                  body: l10n.chatNoAddressesBody,
                  actionLabel: l10n.chatAddAddress,
                  onAction: _openAddAddress,
                )
              else
                ..._addresses.map(
                  (address) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AddressCard(
                      address: address,
                      loading: _isCreating,
                      onTap: () => _startOrderConversation(address),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressSummary address;
  final bool loading;
  final VoidCallback onTap;

  const _AddressCard({
    required this.address,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorsCustom.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: ColorsCustom.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: address.title,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  TextCustom(
                    text: '${address.areaName}، ${address.governorateName}',
                    fontSize: 12,
                    color: ColorsCustom.textSecondary,
                  ),
                ],
              ),
            ),
            loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorsCustom.primary,
                    ),
                  )
                : const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ColorsCustom.textHint,
                  ),
          ],
        ),
      ),
    );
  }
}

class _InfoState extends StatelessWidget {
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const _InfoState({
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: ColorsCustom.textHint,
            size: 42,
          ),
          const SizedBox(height: 12),
          TextCustom(
            text: title,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextCustom(
            text: body,
            fontSize: 12,
            color: ColorsCustom.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ButtonCustom.primary(text: actionLabel, onPressed: onAction),
        ],
      ),
    );
  }
}
