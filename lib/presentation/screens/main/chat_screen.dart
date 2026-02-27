// lib/presentation/screens/main/chat_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/models/chat_message_model.dart';
import 'package:superdriver/domain/services/chat_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  String? _userId;
  String? _userName;
  bool _isSending = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initChat() async {
    // 1. Try ProfileBloc first (may already be loaded)
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _userId = profileState.profileData['id']?.toString();
      _userName = profileState.fullName;
    }

    // 2. Fallback to SecureStorage if ProfileBloc not ready
    if (_userId == null || _userId!.isEmpty) {
      final userData = await secureStorage.getUserData();
      _userId = userData['userId'];
      _userName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
          .trim();
    }

    // 3. Setup chat room if we have a user
    if (_userId != null && _userId!.isNotEmpty) {
      String? phone;
      if (profileState is ProfileLoaded) {
        phone = profileState.phoneNumber;
      } else {
        final userData = await secureStorage.getUserData();
        phone = userData['phone'];
      }

      await chatService.ensureChatRoom(
        userId: _userId!,
        userName: _userName ?? '',
        userPhone: (phone != null && phone.isNotEmpty) ? phone : null,
      );
      await chatService.markAsReadByUser(_userId!);
    }

    if (mounted) setState(() {});
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _userId == null || _isSending) return;

    _controller.clear();
    setState(() => _isSending = true);

    try {
      await chatService.sendTextMessage(
        chatId: _userId!,
        senderId: _userId!,
        text: text,
      );
    } catch (_) {
      // Restore text on failure
      if (mounted) _controller.text = text;
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_userId == null) return;
    Navigator.pop(context); // close bottom sheet
    FocusScope.of(context).unfocus(); // dismiss keyboard

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 60,
      );
      if (picked == null || !mounted) return;

      final file = File(picked.path);

      // Show preview before sending
      final confirmed = await _showImagePreview(file);
      if (confirmed != true || !mounted) return;

      setState(() => _isSending = true);
      await chatService.sendImageMessage(
        chatId: _userId!,
        senderId: _userId!,
        imageFile: file,
      );
    } catch (_) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        final l10n = AppLocalizations.of(context)!;
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.chatImageSendError),
            backgroundColor: ColorsCustom.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<bool?> _showImagePreview(File file) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        // Use MediaQuery inside builder so it reacts to keyboard changes
        final viewInsets = MediaQuery.of(ctx).viewInsets;
        final screenHeight = MediaQuery.of(ctx).size.height;
        final availableHeight = screenHeight - viewInsets.bottom - 120;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image — shrinks with available space ──
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: availableHeight * 0.75),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(file, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),

              // ── Action buttons ──
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: ColorsCustom.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: TextCustom(
                        text: l10n.cancel,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(ctx, true),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: TextCustom(
                        text: l10n.chatSend,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorsCustom.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAttachmentSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        decoration: const BoxDecoration(
          color: ColorsCustom.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AttachOption(
                  icon: Icons.camera_alt_rounded,
                  label: l10n.chatCamera,
                  color: ColorsCustom.primary,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _AttachOption(
                  icon: Icons.photo_library_rounded,
                  label: l10n.chatGallery,
                  color: const Color(0xFF7B1FA2),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FullScreenImage(url: url)),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Still loading profile data — show loading
    if (_userId == null) {
      return Scaffold(
        backgroundColor: ColorsCustom.background,
        appBar: _buildAppBar(l10n),
        body: const Center(
          child: CircularProgressIndicator(
            color: ColorsCustom.primary,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _buildAppBar(l10n),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icons/chat_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // ── Messages list ──
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: chatService.messagesStream(_userId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorsCustom.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return _buildEmptyState(l10n);
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final prevMsg = i < messages.length - 1
                          ? messages[i + 1]
                          : null;
                      final showDateHeader = _shouldShowDate(msg, prevMsg);

                      return Column(
                        children: [
                          if (showDateHeader) _buildDateHeader(msg.createdAt),
                          _MessageBubble(
                            message: msg,
                            onImageTap: msg.isImage && msg.imageUrl != null
                                ? () => _openFullScreenImage(msg.imageUrl!)
                                : null,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // ── Input bar ──
            _buildInputBar(l10n),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================

  AppBar _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      automaticallyImplyLeading: false,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: ColorsCustom.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/support_avatar.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: l10n.chatSupportTitle,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: ColorsCustom.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    TextCustom(
                      text: l10n.chatOnline,
                      fontSize: 12,
                      color: ColorsCustom.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorsCustom.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: ColorsCustom.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            TextCustom(
              text: l10n.chatEmptyTitle,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: l10n.chatEmptySubtitle,
              fontSize: 13,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT BAR
  // ============================================================

  Widget _buildInputBar(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        10,
        12,
        MediaQuery.of(context).padding.bottom + 25,
      ),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Attachment button ──
          GestureDetector(
            onTap: _showAttachmentSheet,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.attach_file_rounded,
                color: ColorsCustom.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Text field ──
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorsCustom.surfaceVariant,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorsCustom.textPrimary,
                  fontFamily: 'Cairo',
                ),
                decoration: InputDecoration(
                  hintText: l10n.chatHint,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: ColorsCustom.textHint,
                    fontFamily: 'Cairo',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Send button ──
          GestureDetector(
            onTap: _isSending ? null : _sendText,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ColorsCustom.primary, ColorsCustom.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _shouldShowDate(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;
    return current.createdAt.day != previous.createdAt.day ||
        current.createdAt.month != previous.createdAt.month ||
        current.createdAt.year != previous.createdAt.year;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final l10n = AppLocalizations.of(context)!;
    String text;

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      text = l10n.chatToday;
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      text = l10n.chatYesterday;
    } else {
      text = '${date.day}/${date.month}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ColorsCustom.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextCustom(
            text: text,
            fontSize: 12,
            color: ColorsCustom.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE BUBBLE
// ============================================================

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onImageTap;

  const _MessageBubble({required this.message, this.onImageTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: isUser
            ? AlignmentDirectional.centerEnd
            : AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: message.isImage
                ? const EdgeInsets.all(4)
                : const EdgeInsets.fromLTRB(14, 10, 14, 6),
            decoration: BoxDecoration(
              color: isUser ? ColorsCustom.primary : ColorsCustom.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              border: isUser ? null : Border.all(color: ColorsCustom.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Content ──
                if (message.isImage && message.imageUrl != null)
                  GestureDetector(
                    onTap: onImageTap,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 200,
                        maxHeight: 200,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          message.imageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              width: 200,
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorsCustom.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
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
                    ),
                  )
                else
                  TextCustom(
                    text: message.text,
                    fontSize: 14,
                    color: isUser ? Colors.white : ColorsCustom.textPrimary,
                  ),

                // ── Time + read status ──
                Padding(
                  padding: EdgeInsets.only(
                    top: message.isImage ? 4 : 2,
                    left: message.isImage ? 8 : 0,
                    right: message.isImage ? 8 : 0,
                    bottom: message.isImage ? 4 : 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextCustom(
                        text: time,
                        fontSize: 11,
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
                              ? const Color(0xFF64B5F6)
                              : Colors.white.withAlpha(180),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ATTACHMENT OPTION
// ============================================================

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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          TextCustom(
            text: label,
            fontSize: 13,
            color: ColorsCustom.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FULL SCREEN IMAGE VIEWER
// ============================================================

class _FullScreenImage extends StatelessWidget {
  final String url;
  const _FullScreenImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
