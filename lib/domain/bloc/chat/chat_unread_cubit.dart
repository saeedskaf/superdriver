import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/data/services/chat_service.dart';

/// Tracks the total number of unread chat messages across all conversations.
///
/// Listens to [ChatService.latestUserConversationsStream] and aggregates
/// the `unreadByUser` field from every conversation into a single [int].
class ChatUnreadCubit extends Cubit<int> {
  ChatUnreadCubit() : super(0);

  StreamSubscription<int>? _subscription;

  /// Begin listening for unread count changes for [userId].
  ///
  /// Cancels any previous subscription before starting a new one.
  void startListening(String userId) {
    _subscription?.cancel();
    _subscription = chatService
        .latestUserConversationsStream(userId)
        .map((conversations) => conversations.fold<int>(
              0,
              (sum, c) => sum + c.unreadByUser,
            ))
        .distinct()
        .listen(
          emit,
          onError: (e) => log('ChatUnreadCubit: stream error: $e'),
        );
  }

  /// Stop listening and reset the count to zero.
  void reset() {
    _subscription?.cancel();
    _subscription = null;
    emit(0);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
