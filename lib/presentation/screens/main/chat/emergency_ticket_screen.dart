import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:superdriver/data/services/chat_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_button.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_conversation_screen.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_support.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class EmergencyTicketScreen extends StatefulWidget {
  const EmergencyTicketScreen({super.key});

  @override
  State<EmergencyTicketScreen> createState() => _EmergencyTicketScreenState();
}

class _EmergencyTicketScreenState extends State<EmergencyTicketScreen> {
  final _relatedOrderController = TextEditingController();
  String _issueCategory = 'order_issue';
  bool _isCreating = false;

  @override
  void dispose() {
    _relatedOrderController.dispose();
    super.dispose();
  }

  Future<void> _createTicket() async {
    if (_isCreating) return;

    final l10n = AppLocalizations.of(context)!;
    final session = await loadChatSession(context);
    if (!mounted || session == null) return;
    final label = _labelFor(_issueCategory, l10n);

    setState(() => _isCreating = true);
    try {
      final conversation = await chatService.createEmergencyTicket(
        userId: session.userId,
        userName: session.userName,
        userPhone: session.userPhone,
        issueCategory: _issueCategory,
        issueLabel: label,
        relatedOrderId: _relatedOrderController.text.trim().isEmpty
            ? null
            : _relatedOrderController.text.trim(),
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
      log('EmergencyTicketScreen: failed to create ticket: $e');
      if (!mounted) return;
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

  String _labelFor(String category, AppLocalizations l10n) {
    switch (category) {
      case 'driver_issue':
        return l10n.chatDriverProblem;
      case 'rating_issue':
        return l10n.chatRatingProblem;
      case 'technical_issue':
        return l10n.chatTechProblem;
      case 'other':
        return l10n.chatOtherProblem;
      case 'order_issue':
      default:
        return l10n.chatOrderProblem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <MapEntry<String, String>>[
      MapEntry('order_issue', l10n.chatOrderProblem),
      MapEntry('driver_issue', l10n.chatDriverProblem),
      MapEntry('rating_issue', l10n.chatRatingProblem),
      MapEntry('technical_issue', l10n.chatTechProblem),
      MapEntry('other', l10n.chatOtherProblem),
    ];

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
          text: l10n.chatEmergencyHeader,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
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
                    color: ColorsCustom.error.withAlpha(22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: ColorsCustom.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: l10n.chatEmergencyTitle,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: ColorsCustom.textPrimary,
                      ),
                      const SizedBox(height: 4),
                      TextCustom(
                        text: l10n.chatEmergencySubtitle,
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ColorsCustom.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ColorsCustom.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.chatIssueCategory,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _issueCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: ColorsCustom.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: options
                      .map(
                        (option) => DropdownMenuItem<String>(
                          value: option.key,
                          child: Text(option.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _issueCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _relatedOrderController,
                  decoration: InputDecoration(
                    labelText: l10n.chatRelatedOrderOptional,
                    hintText: l10n.chatRelatedOrderHint,
                    filled: true,
                    fillColor: ColorsCustom.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ButtonCustom.primary(
                  text: _isCreating ? l10n.chatCreating : l10n.chatStartTicket,
                  onPressed: _isCreating ? null : _createTicket,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
