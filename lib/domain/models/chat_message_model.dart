import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, location, system }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String senderId;
  final String senderType; // "user" | "admin"
  final MessageType type;
  final String? imageUrl;
  final Map<String, dynamic>? locationData;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderType,
    required this.type,
    this.imageUrl,
    this.locationData,
    required this.createdAt,
    this.readAt,
  });

  bool get isUser => senderType == 'user';
  bool get isAdmin => senderType == 'admin';
  bool get isImage => type == MessageType.image;
  bool get isLocation => type == MessageType.location;
  bool get isRead => readAt != null;

  static MessageType _parseType(String? type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'location':
        return MessageType.location;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  static String _typeToString(MessageType type) {
    switch (type) {
      case MessageType.image:
        return 'image';
      case MessageType.location:
        return 'location';
      case MessageType.system:
        return 'system';
      case MessageType.text:
        return 'text';
    }
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      senderType: data['senderType'] ?? 'user',
      type: _parseType(data['type']),
      imageUrl: data['imageUrl'],
      locationData: data['locationData'] != null
          ? Map<String, dynamic>.from(data['locationData'])
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'senderId': senderId,
      'senderType': senderType,
      'type': _typeToString(type),
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (locationData != null) 'locationData': locationData,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  @override
  List<Object?> get props => [id];
}

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
