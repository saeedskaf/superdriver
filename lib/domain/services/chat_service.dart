import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:superdriver/domain/models/chat_message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;
  ChatService._();

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // ============================================================
  // COLLECTIONS
  // ============================================================

  CollectionReference get _chatsRef => _firestore.collection('chats');

  DocumentReference _chatDoc(String chatId) => _chatsRef.doc(chatId);

  CollectionReference _messagesRef(String chatId) =>
      _chatDoc(chatId).collection('messages');

  // ============================================================
  // CHAT ROOM
  // ============================================================

  /// Ensure a chat room document exists for this user.
  /// Creates one if it doesn't exist yet.
  Future<void> ensureChatRoom({
    required String userId,
    required String userName,
    String? userPhone,
  }) async {
    final doc = _chatDoc(userId);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'userName': userName,
        'userPhone': userPhone,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageAt': null,
        'lastMessageBy': null,
        'unreadByAdmin': 0,
        'unreadByUser': 0,
        'status': 'active',
      });
      log('ChatService: Created chat room for user $userId');
    }
  }

  /// Stream the chat room document for unread count updates.
  Stream<ChatRoom?> chatRoomStream(String chatId) {
    return _chatDoc(chatId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatRoom.fromFirestore(doc);
    });
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  /// Real-time stream of messages, ordered newest-first for ListView.
  Stream<List<ChatMessage>> messagesStream(String chatId) {
    return _messagesRef(chatId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  /// Send a text message.
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      text: text,
      senderId: senderId,
      senderType: 'user',
      type: MessageType.text,
      createdAt: DateTime.now(),
    );

    await _messagesRef(chatId).add(message.toFirestore());

    await _chatDoc(chatId).update({
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': 'user',
      'unreadByAdmin': FieldValue.increment(1),
    });

    log('ChatService: Sent text message in chat $chatId');
  }

  /// Upload image to Firebase Storage and send as image message.
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
  }) async {
    // 1. Upload to Storage
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final ref = _storage.ref('chat_images/$chatId/$fileName');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await uploadTask.ref.getDownloadURL();

    log('ChatService: Uploaded image -> $imageUrl');

    // 2. Create message
    final message = ChatMessage(
      id: '',
      text: '📷',
      senderId: senderId,
      senderType: 'user',
      type: MessageType.image,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _messagesRef(chatId).add(message.toFirestore());

    // 3. Update chat room
    await _chatDoc(chatId).update({
      'lastMessage': '📷 صورة',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageBy': 'user',
      'unreadByAdmin': FieldValue.increment(1),
    });
  }

  // ============================================================
  // READ RECEIPTS
  // ============================================================

  /// Mark all admin messages as read by the user.
  Future<void> markAsReadByUser(String chatId) async {
    // Reset unread counter
    await _chatDoc(chatId).update({'unreadByUser': 0});

    // Mark individual messages
    final unreadMessages = await _messagesRef(chatId)
        .where('senderType', isEqualTo: 'admin')
        .where('readAt', isNull: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {'readAt': FieldValue.serverTimestamp()});
    }
    await batch.commit();
  }
}

final chatService = ChatService();
