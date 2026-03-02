import 'dart:developer';
import 'dart:io';
import 'dart:math' show Random;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/chat_conversation_model.dart';
import 'package:superdriver/domain/models/chat_message_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;
  ChatService._();

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  CollectionReference get _chatsRef => _firestore.collection('chats');

  DocumentReference _chatDoc(String conversationId) =>
      _chatsRef.doc(conversationId);

  CollectionReference _messagesRef(String conversationId) =>
      _chatDoc(conversationId).collection('messages');

  String _randomHex({int length = 6}) {
    const chars = '0123456789ABCDEF';
    final rand = Random.secure();
    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  String _timestampToken() {
    final now = DateTime.now();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$year$month$day$hour$minute$second';
  }

  String _conversationId(String userId) {
    return '${userId}_${DateTime.now().microsecondsSinceEpoch}_${_randomHex()}';
  }

  String generateReferenceId(ChatConversationType type) {
    return '${type.referencePrefix}-${_timestampToken()}-${_randomHex()}';
  }

  Future<ChatConversation> createOrderConversation({
    required String userId,
    required String userName,
    String? userPhone,
    required AddressSummary address,
  }) async {
    final conversationId = _conversationId(userId);
    final referenceId = generateReferenceId(ChatConversationType.orderRequest);
    final now = DateTime.now();

    await _chatDoc(conversationId).set({
      'conversationId': conversationId,
      'userId': userId,
      'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      'type': ChatConversationType.orderRequest.firestoreValue,
      'referenceId': referenceId,
      'status': 'open',
      'addressId': address.id,
      'addressTitle': address.title,
      'addressSummary': '${address.areaName}، ${address.governorateName}',
      'lastMessage': null,
      'lastMessageAt': null,
      'lastMessageBy': null,
      'unreadByAdmin': 0,
      'unreadByUser': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await sendSystemMessage(
      conversationId: conversationId,
      text: 'order_conversation_created',
    );

    return ChatConversation(
      id: conversationId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      type: ChatConversationType.orderRequest,
      referenceId: referenceId,
      status: 'open',
      addressId: address.id,
      addressTitle: address.title,
      addressSummary: '${address.areaName}، ${address.governorateName}',
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<ChatConversation> createEmergencyTicket({
    required String userId,
    required String userName,
    String? userPhone,
    required String issueCategory,
    required String issueLabel,
    String? relatedOrderId,
  }) async {
    final conversationId = _conversationId(userId);
    final referenceId = generateReferenceId(
      ChatConversationType.emergencyTicket,
    );
    final now = DateTime.now();

    await _chatDoc(conversationId).set({
      'conversationId': conversationId,
      'userId': userId,
      'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      'type': ChatConversationType.emergencyTicket.firestoreValue,
      'referenceId': referenceId,
      'status': 'open',
      'issueCategory': issueCategory,
      'issueLabel': issueLabel,
      if (relatedOrderId != null && relatedOrderId.isNotEmpty)
        'relatedOrderId': relatedOrderId,
      'addressId': null,
      'addressTitle': null,
      'addressSummary': null,
      'lastMessage': null,
      'lastMessageAt': null,
      'lastMessageBy': null,
      'unreadByAdmin': 0,
      'unreadByUser': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    await sendSystemMessage(
      conversationId: conversationId,
      text: 'emergency_ticket_created',
    );

    return ChatConversation(
      id: conversationId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      type: ChatConversationType.emergencyTicket,
      referenceId: referenceId,
      status: 'open',
      issueCategory: issueCategory,
      issueLabel: issueLabel,
      relatedOrderId: relatedOrderId,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> saveFcmToken({
    required String conversationId,
    required String token,
  }) async {
    try {
      await _chatDoc(conversationId).collection('fcmTokens').doc(token).set({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      log('ChatService: FCM token saved for conversation $conversationId');
    } catch (e) {
      log('ChatService: Failed to save FCM token: $e');
    }
  }

  Future<void> removeFcmTokenForUserConversations({
    required String userId,
    required String token,
  }) async {
    try {
      final snapshot = await _chatsRef.where('userId', isEqualTo: userId).get();
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference.collection('fcmTokens').doc(token));
      }
      await batch.commit();
      log(
        'ChatService: FCM token removed for ${snapshot.docs.length} conversations',
      );
    } catch (e) {
      log('ChatService: Failed to remove FCM token: $e');
    }
  }

  Stream<List<ChatConversation>> userConversationsStream(String userId) {
    return _chatsRef.where('userId', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final conversations =
          snapshot.docs
              .map((doc) => ChatConversation.fromFirestore(doc))
              .toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return conversations;
    });
  }

  Stream<ChatConversation?> conversationStream(String conversationId) {
    return _chatDoc(conversationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatConversation.fromFirestore(doc);
    });
  }

  Stream<List<ChatMessage>> messagesStream(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> sendTextMessage({
    required String conversationId,
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

    await _messagesRef(conversationId).add(message.toFirestore());
    await _updateAfterMessage(conversationId: conversationId, preview: text);
  }

  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required File imageFile,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
    final ref = _storage.ref('chat_images/$conversationId/$fileName');

    final uploadTask = await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final imageUrl = await uploadTask.ref.getDownloadURL();

    final message = ChatMessage(
      id: '',
      text: 'image',
      senderId: senderId,
      senderType: 'user',
      type: MessageType.image,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await _messagesRef(conversationId).add(message.toFirestore());
    await _updateAfterMessage(conversationId: conversationId, preview: '📷');
  }

  Future<void> sendSystemMessage({
    required String conversationId,
    required String text,
  }) async {
    final message = ChatMessage(
      id: '',
      text: text,
      senderId: 'system',
      senderType: 'system',
      type: MessageType.system,
      createdAt: DateTime.now(),
    );

    await _messagesRef(conversationId).add(message.toFirestore());
  }

  Future<void> markAsReadByUser(String conversationId) async {
    await _chatDoc(conversationId).update({'unreadByUser': 0});

    final unreadMessages = await _messagesRef(conversationId)
        .where('senderType', isEqualTo: 'admin')
        .where('readAt', isNull: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'readAt': Timestamp.fromDate(DateTime.now()),
      });
    }
    await batch.commit();
  }

  Future<void> _updateAfterMessage({
    required String conversationId,
    required String preview,
  }) async {
    await _chatDoc(conversationId).update({
      'lastMessage': preview,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'lastMessageBy': 'user',
      'unreadByAdmin': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}

final chatService = ChatService();
