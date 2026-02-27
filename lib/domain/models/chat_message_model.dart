import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// MESSAGE TYPE
// ============================================================

enum MessageType { text, image }

// ============================================================
// CHAT MESSAGE MODEL
// ============================================================

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String senderType; // "user" | "admin"
  final MessageType type;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderType,
    required this.type,
    this.imageUrl,
    required this.createdAt,
    this.readAt,
  });

  bool get isUser => senderType == 'user';
  bool get isAdmin => senderType == 'admin';
  bool get isImage => type == MessageType.image;
  bool get isRead => readAt != null;

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      type: data['type'] == 'image' ? MessageType.image : MessageType.text,
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderType': senderType,
      'type': type == MessageType.image ? 'image' : 'text',
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  @override
  List<Object?> get props => [id];
}

// ============================================================
// CHAT ROOM MODEL (parent document)
// ============================================================

class ChatRoom {
  final String id;
  final String userName;
  final String? userPhone;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final int unreadByAdmin;
  final int unreadByUser;
  final String status;
  final DateTime createdAt;

  const ChatRoom({
    required this.id,
    required this.userName,
    this.userPhone,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    this.unreadByAdmin = 0,
    this.unreadByUser = 0,
    this.status = 'active',
    required this.createdAt,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      userName: data['userName'] ?? '',
      userPhone: data['userPhone'],
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageBy: data['lastMessageBy'],
      unreadByAdmin: data['unreadByAdmin'] ?? 0,
      unreadByUser: data['unreadByUser'] ?? 0,
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
