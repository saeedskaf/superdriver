import 'dart:developer';
import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:superdriver/data/env/environment.dart';
import 'package:superdriver/data/local_secure/secure_storage.dart';
import 'package:superdriver/domain/models/address_model.dart';
import 'package:superdriver/domain/models/chat_conversation_model.dart';
import 'package:superdriver/domain/models/chat_message_model.dart';

class ChatMessagesPage {
  final List<ChatMessage> messages;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const ChatMessagesPage({
    required this.messages,
    required this.lastDocument,
    required this.hasMore,
  });
}

class ChatConversationsPage {
  final List<ChatConversation> conversations;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const ChatConversationsPage({
    required this.conversations,
    required this.lastDocument,
    required this.hasMore,
  });
}

class ChatService {
  static final ChatService _instance = ChatService._();
  factory ChatService() => _instance;
  ChatService._();

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxBatchWrites = 450;

  CollectionReference get _chatsRef => _firestore.collection('chats');

  DocumentReference _chatDoc(String conversationId) =>
      _chatsRef.doc(conversationId);

  CollectionReference _messagesRef(String conversationId) =>
      _chatDoc(conversationId).collection('messages');

  Future<ChatConversation> createOrderConversation({
    required String userId,
    required String userName,
    String? userPhone,
    required AddressSummary address,
  }) async {
    final data = await _createConversationViaFunction({
      'type': ChatConversationType.orderRequest.firestoreValue,
      'userId': userId,
      'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      'address': {
        'id': address.id,
        'title': address.title,
        'areaName': address.areaName,
        'governorateName': address.governorateName,
      },
    });

    final now = DateTime.now();
    return ChatConversation(
      id: data['conversationId']!,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      type: ChatConversationType.orderRequest,
      referenceId: data['referenceId']!,
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
    final data = await _createConversationViaFunction({
      'type': ChatConversationType.emergencyTicket.firestoreValue,
      'userId': userId,
      'userName': userName,
      if (userPhone != null) 'userPhone': userPhone,
      'issueCategory': issueCategory,
      'issueLabel': issueLabel,
      if (relatedOrderId != null && relatedOrderId.isNotEmpty)
        'relatedOrderId': relatedOrderId,
    });

    final now = DateTime.now();
    return ChatConversation(
      id: data['conversationId']!,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      type: ChatConversationType.emergencyTicket,
      referenceId: data['referenceId']!,
      status: 'open',
      issueCategory: issueCategory,
      issueLabel: issueLabel,
      relatedOrderId: relatedOrderId,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Map<String, String>> _createConversationViaFunction(
    Map<String, dynamic> payload,
  ) async {
    final token = await secureStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing access token');
    }

    final response = await http
        .post(
          Uri.parse(Environment.createChatConversationEndpoint),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    final responseData = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = _extractErrorMessage(responseData);
      throw Exception(
        error.isEmpty ? 'Failed to create chat conversation' : error,
      );
    }

    if (responseData is! Map<String, dynamic>) {
      throw StateError('createChatConversation returned invalid payload');
    }
    final conversationId = responseData['conversationId']?.toString();
    final referenceId = responseData['referenceId']?.toString();
    if (conversationId == null ||
        conversationId.isEmpty ||
        referenceId == null ||
        referenceId.isEmpty) {
      throw StateError(
        'createChatConversation returned empty conversationId/referenceId',
      );
    }
    return {'conversationId': conversationId, 'referenceId': referenceId};
  }

  String _extractErrorMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['error']?.toString();
      if (message != null && message.isNotEmpty) return message;
      for (final value in body.values) {
        if (value is String && value.isNotEmpty) return value;
        if (value is List && value.isNotEmpty) return value.first.toString();
      }
    }
    return '';
  }

  Future<void> saveFcmToken({
    required String conversationId,
    required String token,
    String locale = 'ar',
  }) async {
    try {
      await _chatDoc(conversationId).collection('fcmTokens').doc(token).set({
        'token': token,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'locale': locale,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      log('ChatService: FCM token saved for conversation $conversationId');
    } catch (e) {
      log('ChatService: Failed to save FCM token: $e');
    }
  }

  Future<void> updateFcmTokenLocale({
    required String userId,
    required String token,
    required String locale,
  }) async {
    try {
      final snapshot =
          await _chatsRef.where('userId', isEqualTo: userId).get();
      for (var i = 0; i < snapshot.docs.length; i += _maxBatchWrites) {
        final batch = _firestore.batch();
        final end = (i + _maxBatchWrites > snapshot.docs.length)
            ? snapshot.docs.length
            : i + _maxBatchWrites;
        for (final doc in snapshot.docs.sublist(i, end)) {
          batch.update(
            doc.reference.collection('fcmTokens').doc(token),
            {'locale': locale},
          );
        }
        await batch.commit();
      }
    } catch (e) {
      log('ChatService: Failed to update FCM token locale: $e');
    }
  }

  Future<void> removeFcmTokenForUserConversations({
    required String userId,
    required String token,
  }) async {
    try {
      final snapshot = await _chatsRef.where('userId', isEqualTo: userId).get();
      final docs = snapshot.docs;
      for (var i = 0; i < docs.length; i += _maxBatchWrites) {
        final batch = _firestore.batch();
        final end = (i + _maxBatchWrites > docs.length)
            ? docs.length
            : i + _maxBatchWrites;
        for (final doc in docs.sublist(i, end)) {
          batch.delete(doc.reference.collection('fcmTokens').doc(token));
        }
        await batch.commit();
      }
      log(
        'ChatService: FCM token removed for ${snapshot.docs.length} conversations',
      );
    } catch (e) {
      log('ChatService: Failed to remove FCM token: $e');
    }
  }

  Stream<List<ChatConversation>> latestUserConversationsStream(
    String userId, {
    int limit = 20,
  }) {
    return _chatsRef
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatConversation.fromFirestore(doc))
              .toList(),
        );
  }

  Future<ChatConversationsPage> fetchUserConversationsPage(
    String userId, {
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    Query query = _chatsRef
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final conversations = snapshot.docs
        .map((doc) => ChatConversation.fromFirestore(doc))
        .toList();

    return ChatConversationsPage(
      conversations: conversations,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : startAfter,
      hasMore: snapshot.docs.length == limit,
    );
  }

  Stream<ChatConversation?> conversationStream(String conversationId) {
    return _chatDoc(conversationId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChatConversation.fromFirestore(doc);
    });
  }

  Stream<List<ChatMessage>> latestMessagesStream(
    String conversationId, {
    int limit = 25,
  }) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  Future<ChatMessagesPage> fetchMessagesPage(
    String conversationId, {
    DocumentSnapshot? startAfter,
    int limit = 25,
  }) async {
    Query query = _messagesRef(
      conversationId,
    ).orderBy('createdAt', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final messages = snapshot.docs
        .map((doc) => ChatMessage.fromFirestore(doc))
        .toList();

    return ChatMessagesPage(
      messages: messages,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : startAfter,
      hasMore: snapshot.docs.length == limit,
    );
  }

  Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String text,
  }) async {
    await _ensureConversationOpen(conversationId);

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
    await _ensureConversationOpen(conversationId);

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
    final unreadMessages = await _messagesRef(conversationId)
        .where('senderType', isEqualTo: 'admin')
        .where('readAt', isNull: true)
        .get();

    final docs = unreadMessages.docs;
    if (docs.isNotEmpty) {
      final now = FieldValue.serverTimestamp();
      for (var i = 0; i < docs.length; i += _maxBatchWrites) {
        final batch = _firestore.batch();
        final end = (i + _maxBatchWrites > docs.length)
            ? docs.length
            : i + _maxBatchWrites;
        for (final doc in docs.sublist(i, end)) {
          batch.update(doc.reference, {'readAt': now});
        }
        await batch.commit();
      }
    }

    await _chatDoc(conversationId).update({'unreadByUser': 0});
  }

  Future<void> _updateAfterMessage({
    required String conversationId,
    required String preview,
  }) async {
    final now = FieldValue.serverTimestamp();
    await _chatDoc(conversationId).update({
      'lastMessage': preview,
      'lastMessageAt': now,
      'lastMessageBy': 'user',
      'unreadByAdmin': FieldValue.increment(1),
      'updatedAt': now,
    });
  }

  Future<void> _ensureConversationOpen(String conversationId) async {
    final doc = await _chatDoc(conversationId).get();
    if (!doc.exists) {
      throw StateError('Conversation not found');
    }

    final data = doc.data();
    if (data is! Map<String, dynamic>) {
      throw StateError('Invalid conversation payload');
    }

    final status = data['status']?.toString().toLowerCase() ?? 'open';
    if (status == 'closed') {
      throw StateError('Conversation is closed');
    }
  }
}

final chatService = ChatService();
