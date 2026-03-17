import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ChatConversationType { orderRequest, emergencyTicket }

extension ChatConversationTypeX on ChatConversationType {
  String get firestoreValue {
    switch (this) {
      case ChatConversationType.orderRequest:
        return 'order_request';
      case ChatConversationType.emergencyTicket:
        return 'emergency_ticket';
    }
  }

  String get referencePrefix {
    switch (this) {
      case ChatConversationType.orderRequest:
        return 'ORD-CHAT';
      case ChatConversationType.emergencyTicket:
        return 'TIC-CHAT';
    }
  }

  static ChatConversationType fromValue(String? value) {
    switch (value) {
      case 'emergency_ticket':
        return ChatConversationType.emergencyTicket;
      case 'order_request':
      default:
        return ChatConversationType.orderRequest;
    }
  }
}

class ChatConversation extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhone;
  final ChatConversationType type;
  final String referenceId;
  final String status;
  final int? addressId;
  final String? addressTitle;
  final String? addressSummary;
  final String? issueCategory;
  final String? issueLabel;
  final String? relatedOrderId;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageBy;
  final int unreadByAdmin;
  final int unreadByUser;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhone,
    required this.type,
    required this.referenceId,
    required this.status,
    this.addressId,
    this.addressTitle,
    this.addressSummary,
    this.issueCategory,
    this.issueLabel,
    this.relatedOrderId,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    this.unreadByAdmin = 0,
    this.unreadByUser = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOrderRequest => type == ChatConversationType.orderRequest;
  bool get isEmergencyTicket => type == ChatConversationType.emergencyTicket;

  factory ChatConversation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = DateTime.now();
    return ChatConversation(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString() ?? '',
      userPhone: data['userPhone']?.toString(),
      type: ChatConversationTypeX.fromValue(data['type']?.toString()),
      referenceId: data['referenceId']?.toString() ?? '',
      status: data['status']?.toString() ?? 'open',
      addressId: data['addressId'] is int
          ? data['addressId'] as int
          : int.tryParse(data['addressId']?.toString() ?? ''),
      addressTitle: data['addressTitle']?.toString(),
      addressSummary: data['addressSummary']?.toString(),
      issueCategory: data['issueCategory']?.toString(),
      issueLabel: data['issueLabel']?.toString(),
      relatedOrderId: data['relatedOrderId']?.toString(),
      lastMessage: data['lastMessage']?.toString(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      lastMessageBy: data['lastMessageBy']?.toString(),
      unreadByAdmin: data['unreadByAdmin'] as int? ?? 0,
      unreadByUser: data['unreadByUser'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? now,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? now,
    );
  }

  @override
  List<Object?> get props => [id, updatedAt, lastMessage];
}
