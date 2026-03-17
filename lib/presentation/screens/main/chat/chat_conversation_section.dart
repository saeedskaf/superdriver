import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class ChatConversationList extends StatefulWidget {
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
  State<ChatConversationList> createState() => _ChatConversationListState();
}

class _ChatConversationListState extends State<ChatConversationList> {
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();
  StreamSubscription<List<ChatConversation>>? _latestConversationsSub;
  int _activeSessionRequestId = 0;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  List<ChatConversation> _conversations = const [];
  DocumentSnapshot? _lastConversationDoc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initialize();
  }

  @override
  void didUpdateWidget(covariant ChatConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.isSessionLoading != widget.isSessionLoading) {
      _resetState();
      _initialize();
    }
  }

  @override
  void dispose() {
    _latestConversationsSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _resetState() {
    _latestConversationsSub?.cancel();
    _latestConversationsSub = null;
    _isLoading = true;
    _isLoadingMore = false;
    _hasMore = true;
    _error = null;
    _conversations = const [];
    _lastConversationDoc = null;
  }

  Future<void> _initialize() async {
    final userId = widget.userId;
    if (widget.isSessionLoading || userId == null) return;
    final requestId = ++_activeSessionRequestId;
    await _loadInitial(userId: userId, requestId: requestId);
    if (!mounted ||
        requestId != _activeSessionRequestId ||
        widget.userId != userId) {
      return;
    }
    _listenForLatestUpdates(userId: userId, requestId: requestId);
  }

  Future<void> _loadInitial({
    required String userId,
    required int requestId,
  }) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await chatService.fetchUserConversationsPage(
        userId,
        limit: _pageSize,
      );
      if (!mounted ||
          requestId != _activeSessionRequestId ||
          userId != widget.userId) {
        return;
      }
      setState(() {
        _conversations = page.conversations;
        _lastConversationDoc = page.lastDocument;
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      log(
        'ChatConversationList: initial load failed: $e',
        stackTrace: stackTrace,
      );
      if (!mounted ||
          requestId != _activeSessionRequestId ||
          userId != widget.userId) {
        return;
      }
      setState(() {
        _error = AppLocalizations.of(context)?.chatConversationsLoadError;
        _isLoading = false;
      });
    }
  }

  void _listenForLatestUpdates({
    required String userId,
    required int requestId,
  }) {
    _latestConversationsSub?.cancel();
    _latestConversationsSub = chatService
        .latestUserConversationsStream(userId, limit: _pageSize)
        .listen(
          (latestConversations) {
            if (!mounted ||
                requestId != _activeSessionRequestId ||
                userId != widget.userId) {
              return;
            }
            setState(() {
              _conversations = _mergeConversations(
                current: _conversations,
                incoming: latestConversations,
              );
              _error = null;
            });
          },
          onError: (error, stackTrace) {
            log(
              'ChatConversationList: stream failed: $error',
              stackTrace: stackTrace,
            );
          },
        );
  }

  Future<void> _loadMore() async {
    final userId = widget.userId;
    if (userId == null || _isLoadingMore || !_hasMore) return;
    final cursor = _lastConversationDoc;
    if (cursor == null) return;

    setState(() => _isLoadingMore = true);
    try {
      final page = await chatService.fetchUserConversationsPage(
        userId,
        startAfter: cursor,
        limit: _pageSize,
      );
      if (!mounted || userId != widget.userId) return;

      final existingIds = _conversations.map((c) => c.id).toSet();
      final olderItems = page.conversations
          .where((conversation) => !existingIds.contains(conversation.id))
          .toList();

      setState(() {
        _conversations = [..._conversations, ...olderItems];
        _lastConversationDoc = page.lastDocument ?? _lastConversationDoc;
        _hasMore = page.hasMore;
        _isLoadingMore = false;
      });
    } catch (e, stackTrace) {
      log('ChatConversationList: load more failed: $e', stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent < 120) return;
    final threshold = position.maxScrollExtent - 140;
    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  List<ChatConversation> _mergeConversations({
    required List<ChatConversation> current,
    required List<ChatConversation> incoming,
  }) {
    final mergedById = {
      for (final conversation in current) conversation.id: conversation,
    };
    for (final conversation in incoming) {
      mergedById[conversation.id] = conversation;
    }

    final merged = mergedById.values.toList();
    merged.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return merged;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedPadding = widget.padding.resolve(Directionality.of(context));
    final listPadding = EdgeInsets.fromLTRB(
      resolvedPadding.left,
      resolvedPadding.top,
      resolvedPadding.right,
      resolvedPadding.bottom + MediaQuery.of(context).padding.bottom + 96,
    );

    if (widget.isSessionLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    if (widget.userId == null) {
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

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    if (_error != null && _conversations.isEmpty) {
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
                text: _error!,
                fontSize: 13,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  final userId = widget.userId;
                  if (userId == null) return;
                  final requestId = ++_activeSessionRequestId;
                  _loadInitial(userId: userId, requestId: requestId);
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
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
                  border: Border.all(color: ColorsCustom.primary.withAlpha(25)),
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
      controller: _scrollController,
      padding: listPadding,
      itemBuilder: (context, index) {
        if (index == _conversations.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: ColorsCustom.primary,
                ),
              ),
            ),
          );
        }

        return _ConversationTile(
          conversation: _conversations[index],
          showOrderAddress: widget.showOrderAddress,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: _conversations.length + (_isLoadingMore ? 1 : 0),
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
                : ColorsCustom.chatDivider,
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
                    : ColorsCustom.primarySoft,
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
                              : ColorsCustom.chatChip,
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
                          color: isOrder
                              ? ColorsCustom.secondarySoft
                              : ColorsCustom.primarySoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: TextCustom(
                          text: conversation.referenceId,
                          fontSize: 10,
                          color: isOrder
                              ? ColorsCustom.secondaryDark
                              : ColorsCustom.error,
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
