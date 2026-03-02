import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:superdriver/data/services/chat_service.dart';
import 'package:superdriver/domain/models/chat_conversation_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_conversation_screen.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_support.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ChatConversationSection extends StatefulWidget {
  final EdgeInsetsGeometry padding;
  final bool showOrderAddress;

  const ChatConversationSection({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.showOrderAddress = true,
  });

  @override
  State<ChatConversationSection> createState() =>
      _ChatConversationSectionState();
}

class _ChatConversationSectionState extends State<ChatConversationSection> {
  bool _isSessionLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final session = await loadChatSession(context);
    if (!mounted) return;
    setState(() {
      _userId = session?.userId;
      _isSessionLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChatConversationList(
      isSessionLoading: _isSessionLoading,
      userId: _userId,
      padding: widget.padding,
      showOrderAddress: widget.showOrderAddress,
    );
  }
}

class ChatConversationList extends StatelessWidget {
  final bool isSessionLoading;
  final String? userId;
  final EdgeInsetsGeometry padding;
  final bool showOrderAddress;

  const ChatConversationList({
    super.key,
    required this.isSessionLoading,
    required this.userId,
    this.padding = const EdgeInsets.all(16),
    this.showOrderAddress = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isSessionLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    if (userId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: ColorsCustom.error,
                size: 46,
              ),
              const SizedBox(height: 12),
              TextCustom(
                text: l10n.chatSessionUnavailable,
                fontSize: 13,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<ChatConversation>>(
      stream: chatService.userConversationsStream(userId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: ColorsCustom.primary),
          );
        }

        if (snapshot.hasError) {
          log(
            'ChatConversationList: failed to load conversations: ${snapshot.error}',
          );
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: ColorsCustom.error,
                    size: 46,
                  ),
                  const SizedBox(height: 12),
                  TextCustom(
                    text: l10n.chatConversationsLoadError,
                    fontSize: 13,
                    color: ColorsCustom.textPrimary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final conversations = snapshot.data ?? const [];

        if (conversations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: ColorsCustom.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsCustom.primary.withAlpha(25),
                      ),
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: ColorsCustom.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextCustom(
                    text: l10n.chatNoConversations,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                  const SizedBox(height: 8),
                  TextCustom(
                    text: l10n.chatNoConversationsBody,
                    fontSize: 12,
                    color: ColorsCustom.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: padding,
          itemBuilder: (context, index) => _ConversationTile(
            conversation: conversations[index],
            showOrderAddress: showOrderAddress,
          ),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemCount: conversations.length,
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool showOrderAddress;

  const _ConversationTile({
    required this.conversation,
    required this.showOrderAddress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOrder = conversation.isOrderRequest;
    final title = isOrder
        ? l10n.chatOrderRequestLabel
        : l10n.chatEmergencyTicketLabel;
    final subtitle = isOrder
        ? (conversation.addressTitle ?? '')
        : conversation.issueLabel ?? l10n.chatEmergencyTitle;
    final isOpen = conversation.status == 'open';
    final hasUnread = conversation.unreadByUser > 0;

    String? lastMessagePreview;
    if ((conversation.lastMessage ?? '').isNotEmpty) {
      final senderPrefix = conversation.lastMessageBy == 'user'
          ? l10n.chatYou
          : l10n.chatAdmin;
      lastMessagePreview = '$senderPrefix: ${conversation.lastMessage}';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatConversationScreen(conversationId: conversation.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasUnread
                ? ColorsCustom.primary.withAlpha(40)
                : const Color(0xFFE7EBF3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isOrder
                    ? ColorsCustom.secondarySoft
                    : ColorsCustom.error.withAlpha(28),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isOrder
                    ? Icons.shopping_bag_rounded
                    : Icons.report_problem_rounded,
                color: isOrder
                    ? ColorsCustom.secondaryDark
                    : ColorsCustom.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextCustom(
                          text: title,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ColorsCustom.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? ColorsCustom.success.withAlpha(18)
                              : const Color(0xFFF1F4F8),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? ColorsCustom.success
                                    : ColorsCustom.textHint,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextCustom(
                              text: isOpen
                                  ? l10n.chatStatusOpen
                                  : l10n.chatStatusClosed,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isOpen
                                  ? ColorsCustom.success
                                  : ColorsCustom.textHint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsCustom.secondarySoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: TextCustom(
                          text: conversation.referenceId,
                          fontSize: 10,
                          color: ColorsCustom.secondaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isOrder || showOrderAddress) ...[
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextCustom(
                            text: subtitle,
                            fontSize: 11,
                            color: ColorsCustom.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (lastMessagePreview != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextCustom(
                            text: lastMessagePreview,
                            fontSize: 12,
                            color: hasUnread
                                ? ColorsCustom.textPrimary
                                : ColorsCustom.textSecondary,
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w400,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextCustom(
                          text: formatConversationTime(
                            conversation.lastMessageAt ??
                                conversation.updatedAt,
                          ),
                          fontSize: 10,
                          color: hasUnread
                              ? ColorsCustom.primary
                              : ColorsCustom.textHint,
                          fontWeight: hasUnread
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: ColorsCustom.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: TextCustom(
                  text: conversation.unreadByUser > 99
                      ? '99+'
                      : conversation.unreadByUser.toString(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
