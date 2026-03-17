import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superdriver/data/services/chat_service.dart';
import 'package:superdriver/data/services/push_notification_service.dart';
import 'package:superdriver/domain/models/chat_conversation_model.dart';
import 'package:superdriver/domain/models/chat_message_model.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/screens/main/chat/chat_support.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ChatConversationScreen extends StatefulWidget {
  final String conversationId;

  const ChatConversationScreen({super.key, required this.conversationId});

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  static const int _messagesPageSize = 25;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messageFocusNode = FocusNode();
  final _imagePicker = ImagePicker();
  StreamSubscription<List<ChatMessage>>? _latestMessagesSub;
  bool _isInitializing = true;
  bool _sessionUnavailable = false;
  String? _userId;
  bool _isSending = false;
  bool _isLoadingMessages = true;
  bool _isLoadingMoreMessages = false;
  bool _hasMoreMessages = true;
  bool _isMarkingRead = false;
  String? _messagesError;
  List<ChatMessage> _messages = const [];
  DocumentSnapshot? _oldestMessageDoc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _latestMessagesSub?.cancel();
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final session = await loadChatSession(context);
      if (session == null) {
        if (!mounted) return;
        setState(() => _sessionUnavailable = true);
        return;
      }

      _userId = session.userId;

      await _markConversationAsRead();

      final fcmToken = await pushNotificationService.getFcmToken();
      if (fcmToken != null) {
        try {
          final locale =
              Localizations.localeOf(context).languageCode;
          await chatService.saveFcmToken(
            conversationId: widget.conversationId,
            token: fcmToken,
            locale: locale,
          );
        } catch (e, stackTrace) {
          log(
            'ChatConversationScreen: save FCM token failed: $e',
            stackTrace: stackTrace,
          );
        }
      }

      await _loadInitialMessages();

      _latestMessagesSub = chatService
          .latestMessagesStream(widget.conversationId, limit: _messagesPageSize)
          .listen(
            (latestMessages) {
              if (!mounted) return;
              setState(() {
                _messages = _mergeMessages(
                  current: _messages,
                  incoming: latestMessages,
                );
                _messagesError = null;
              });
              _markAdminMessagesAsRead(latestMessages);
            },
            onError: (error, stackTrace) {
              log(
                'ChatConversationScreen: messages stream failed: $error',
                stackTrace: stackTrace,
              );
              if (!mounted) return;
              setState(
                () => _messagesError = AppLocalizations.of(
                  context,
                )?.chatMessagesLoadError,
              );
            },
          );
    } catch (e, stackTrace) {
      log('ChatConversationScreen: init failed: $e', stackTrace: stackTrace);
      if (!mounted) return;
      setState(
        () => _messagesError = AppLocalizations.of(
          context,
        )?.chatMessagesLoadError,
      );
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _loadInitialMessages() async {
    setState(() {
      _isLoadingMessages = true;
      _messagesError = null;
    });

    try {
      final page = await chatService.fetchMessagesPage(
        widget.conversationId,
        limit: _messagesPageSize,
      );

      if (!mounted) return;
      setState(() {
        _messages = page.messages;
        _oldestMessageDoc = page.lastDocument;
        _hasMoreMessages = page.hasMore;
        _isLoadingMessages = false;
      });
      _markAdminMessagesAsRead(page.messages);
    } catch (e, stackTrace) {
      log(
        'ChatConversationScreen: initial messages load failed: $e',
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _messagesError = AppLocalizations.of(context)!.chatMessagesLoadError;
        _isLoadingMessages = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMoreMessages || !_hasMoreMessages) return;
    final cursor = _oldestMessageDoc;
    if (cursor == null) return;

    setState(() => _isLoadingMoreMessages = true);
    try {
      final page = await chatService.fetchMessagesPage(
        widget.conversationId,
        startAfter: cursor,
        limit: _messagesPageSize,
      );

      if (!mounted) return;

      final existingIds = _messages.map((m) => m.id).toSet();
      final olderMessages = page.messages
          .where((message) => !existingIds.contains(message.id))
          .toList();

      setState(() {
        _messages = [..._messages, ...olderMessages];
        _oldestMessageDoc = page.lastDocument ?? _oldestMessageDoc;
        _hasMoreMessages = page.hasMore;
        _isLoadingMoreMessages = false;
      });
      _markAdminMessagesAsRead(olderMessages);
    } catch (e, stackTrace) {
      log(
        'ChatConversationScreen: load more messages failed: $e',
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() => _isLoadingMoreMessages = false);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent < 120) return;
    final threshold = position.maxScrollExtent - 140;
    if (position.pixels >= threshold) {
      _loadMoreMessages();
    }
  }

  void _markAdminMessagesAsRead(List<ChatMessage> messages) {
    final hasUnreadAdmin = messages.any((m) => m.isAdmin && !m.isRead);
    if (hasUnreadAdmin && !_isMarkingRead) {
      _markConversationAsRead();
    }
  }

  Future<void> _markConversationAsRead() async {
    if (_isMarkingRead) return;
    _isMarkingRead = true;
    try {
      await chatService.markAsReadByUser(widget.conversationId);
    } catch (e, stackTrace) {
      log(
        'ChatConversationScreen: mark-as-read failed: $e',
        stackTrace: stackTrace,
      );
    } finally {
      _isMarkingRead = false;
    }
  }

  List<ChatMessage> _mergeMessages({
    required List<ChatMessage> current,
    required List<ChatMessage> incoming,
  }) {
    final mergedById = {for (final message in current) message.id: message};
    for (final message in incoming) {
      mergedById[message.id] = message;
    }

    final merged = mergedById.values.toList();
    merged.sort((a, b) {
      final compare = b.createdAt.compareTo(a.createdAt);
      if (compare != 0) return compare;
      return b.id.compareTo(a.id);
    });
    return merged;
  }

  Future<void> _sendText() async {
    final userId = _userId;
    final text = _controller.text.trim();
    if (userId == null || text.isEmpty || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);
    try {
      await chatService.sendTextMessage(
        conversationId: widget.conversationId,
        senderId: userId,
        text: text,
      );
    } catch (e) {
      if (!mounted) return;
      _controller.text = text;
      final l10n = AppLocalizations.of(context)!;
      final raw = e.toString().replaceFirst('Exception: ', '').trim();
      final message = raw.toLowerCase().contains('closed')
          ? l10n.chatConversationClosed
          : (raw.isNotEmpty ? raw : l10n.chatMessagesLoadError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: ColorsCustom.error),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final userId = _userId;
    if (userId == null || _isSending) return;

    Navigator.pop(context);

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (picked == null) return;

      setState(() => _isSending = true);
      await chatService.sendImageMessage(
        conversationId: widget.conversationId,
        senderId: userId,
        imageFile: File(picked.path),
      );
    } catch (e, stackTrace) {
      log(
        'ChatConversationScreen: image send failed: $e',
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatImageSendError),
          backgroundColor: ColorsCustom.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showAttachSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ColorsCustom.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _AttachOption(
                        icon: Icons.camera_alt_rounded,
                        label: l10n.chatCamera,
                        color: ColorsCustom.primary,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AttachOption(
                        icon: Icons.photo_library_rounded,
                        label: l10n.chatGallery,
                        color: ColorsCustom.secondaryDark,
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullImageViewer(imageUrl: imageUrl)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.chatBackground,
      appBar: AppBar(
        backgroundColor: ColorsCustom.chatBackground,
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
        title: StreamBuilder<ChatConversation?>(
          stream: chatService.conversationStream(widget.conversationId),
          builder: (context, snapshot) {
            final conversation = snapshot.data;
            final title = conversation == null
                ? l10n.chatOpenNewOrder
                : conversation.isOrderRequest
                ? l10n.chatOrderRequestLabel
                : l10n.chatEmergencyTicketLabel;
            return Column(
              children: [
                TextCustom(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                if (conversation != null)
                  TextCustom(
                    text: conversation.referenceId,
                    fontSize: 11,
                    color: ColorsCustom.textHint,
                  ),
              ],
            );
          },
        ),
        centerTitle: true,
      ),
      body: _isInitializing
          ? const Center(
              child: CircularProgressIndicator(color: ColorsCustom.primary),
            )
          : _sessionUnavailable
          ? Center(
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
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                children: [
                  StreamBuilder<ChatConversation?>(
                    stream: chatService.conversationStream(
                      widget.conversationId,
                    ),
                    builder: (context, snapshot) {
                      final conversation = snapshot.data;
                      if (conversation == null) {
                        return const SizedBox.shrink();
                      }
                      return _ConversationHeader(conversation: conversation);
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Container(color: Colors.white),
                            ),
                            Positioned.fill(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Image.asset(
                                  'assets/icons/chat_background.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            _buildMessagesList(l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<ChatConversation?>(
                    stream: chatService.conversationStream(
                      widget.conversationId,
                    ),
                    builder: (context, snapshot) {
                      final isClosed = snapshot.data?.status == 'closed';
                      if (isClosed) {
                        return _ClosedBanner(text: l10n.chatConversationClosed);
                      }
                      return _InputBar(
                        controller: _controller,
                        focusNode: _messageFocusNode,
                        isSending: _isSending,
                        hintText: l10n.chatHint,
                        onSend: _sendText,
                        onAttach: _showAttachSheet,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  bool _shouldShowDate(List<ChatMessage> messages, int index) {
    if (index == messages.length - 1) return true;
    final current = messages[index].createdAt;
    final next = messages[index + 1].createdAt;
    return current.year != next.year ||
        current.month != next.month ||
        current.day != next.day;
  }

  Widget _buildMessagesList(AppLocalizations l10n) {
    if (_isLoadingMessages) {
      return const Center(
        child: CircularProgressIndicator(color: ColorsCustom.primary),
      );
    }

    if (_messagesError != null && _messages.isEmpty) {
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
                text: _messagesError!,
                fontSize: 13,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _loadInitialMessages,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: ColorsCustom.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorsCustom.primary.withAlpha(30)),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: ColorsCustom.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              TextCustom(
                text: l10n.chatEmptyConversation,
                fontSize: 13,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      itemCount: _messages.length + (_isLoadingMoreMessages ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
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

        final message = _messages[index];
        final showDateSep = _shouldShowDate(_messages, index);

        return Column(
          children: [
            if (showDateSep) _DateSeparator(date: message.createdAt),
            _MessageBubble(message: message, onImageTap: _openImageViewer),
          ],
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.hintText,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        MediaQuery.of(context).padding.bottom + 4,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorsCustom.chatDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: ColorsCustom.primary.withAlpha(35)),
            ),
            child: IconButton(
              onPressed: isSending ? null : onAttach,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              color: ColorsCustom.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 42),
              decoration: BoxDecoration(
                color: ColorsCustom.chatInput,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ColorsCustom.chatBorder),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                minLines: 1,
                maxLines: 4,
                onEditingComplete: () {},
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                  fontSize: 13,
                  color: ColorsCustom.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    color: ColorsCustom.textHint,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColorsCustom.primary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClosedBanner extends StatelessWidget {
  final String text;

  const _ClosedBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        MediaQuery.of(context).padding.bottom + 4,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: ColorsCustom.chatChip,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorsCustom.chatBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: ColorsCustom.textHint,
          ),
          const SizedBox(width: 8),
          TextCustom(
            text: text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textHint,
          ),
        ],
      ),
    );
  }
}

class _ConversationHeader extends StatelessWidget {
  final ChatConversation conversation;

  const _ConversationHeader({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isOrder = conversation.isOrderRequest;

    final subtitle = isOrder
        ? (conversation.addressTitle ?? '')
        : conversation.issueLabel ?? l10n.chatEmergencyTitle;

    final statusText = conversation.status == 'open'
        ? l10n.chatStatusOpen
        : l10n.chatStatusClosed;
    final statusColor = conversation.status == 'open'
        ? ColorsCustom.success
        : ColorsCustom.textHint;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorsCustom.surface, ColorsCustom.chatBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsCustom.chatDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
              color: isOrder ? ColorsCustom.secondaryDark : ColorsCustom.error,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: subtitle,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ColorsCustom.textPrimary,
                ),
                if ((conversation.relatedOrderId ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  TextCustom(
                    text:
                        '${l10n.chatRelatedOrder}: ${conversation.relatedOrderId}',
                    fontSize: 11,
                    color: ColorsCustom.textSecondary,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                TextCustom(
                  text: statusText,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: ColorsCustom.chatBorder, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextCustom(
              text: formatDateSeparator(date, l10n),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textHint,
            ),
          ),
          const Expanded(child: Divider(color: ColorsCustom.chatBorder, height: 1)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final void Function(String imageUrl)? onImageTap;

  const _MessageBubble({required this.message, this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSystem = message.senderType == 'system';
    final isUser = message.isUser;
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    final displayText = isSystem
        ? (message.text == 'order_conversation_created'
              ? l10n.chatSystemCreatedOrder
              : message.text == 'emergency_ticket_created'
              ? l10n.chatSystemCreatedIssue
              : message.text)
        : message.text;

    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: ColorsCustom.chatChip,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: ColorsCustom.textHint,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: TextCustom(
                    text: displayText,
                    fontSize: 11,
                    color: ColorsCustom.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: isUser
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: message.isImage
              ? const EdgeInsets.all(4)
              : const EdgeInsets.fromLTRB(14, 11, 14, 8),
          decoration: BoxDecoration(
            color: isUser ? ColorsCustom.primary : ColorsCustom.chatBubble,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 18),
            ),
            border: isUser ? null : Border.all(color: ColorsCustom.chatBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(6),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.isImage && message.imageUrl != null)
                GestureDetector(
                  onTap: () => onImageTap?.call(message.imageUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      message.imageUrl!,
                      width: 200,
                      height: 160,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 200,
                          height: 160,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              color: isUser
                                  ? Colors.white
                                  : ColorsCustom.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, error, stack) => Container(
                        width: 200,
                        height: 100,
                        decoration: BoxDecoration(
                          color: ColorsCustom.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.broken_image_rounded,
                          color: ColorsCustom.textHint,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                )
              else
                TextCustom(
                  text: displayText,
                  fontSize: 13,
                  color: isUser ? Colors.white : ColorsCustom.textPrimary,
                ),
              Padding(
                padding: message.isImage
                    ? const EdgeInsets.fromLTRB(10, 4, 10, 2)
                    : const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(
                      text: time,
                      fontSize: 10,
                      color: isUser
                          ? Colors.white.withAlpha(180)
                          : ColorsCustom.textHint,
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead
                            ? Icons.done_all_rounded
                            : Icons.done_rounded,
                        size: 14,
                        color: message.isRead
                            ? Colors.white
                            : Colors.white.withAlpha(150),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _FullImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
