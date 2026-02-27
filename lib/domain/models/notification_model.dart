// lib/domain/models/notification_model.dart

/// Notification list item — from GET /api/notifications/
class NotificationItem {
  final int id;
  final String notificationType;
  final String title;
  final String? titleEn;
  final String body;
  final String? bodyEn;
  final bool isRead;
  final DateTime createdAt;

  const NotificationItem({
    required this.id,
    required this.notificationType,
    required this.title,
    this.titleEn,
    required this.body,
    this.bodyEn,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? 0,
      notificationType: json['notification_type'] ?? '',
      title: json['title'] ?? '',
      titleEn: json['title_en'],
      body: json['body'] ?? '',
      bodyEn: json['body_en'],
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// Notification detail — from GET /api/notifications/{id}/
class NotificationDetail {
  final int id;
  final String notificationType;
  final String title;
  final String? titleEn;
  final String body;
  final String? bodyEn;
  final String? imageUrl;
  final String? referenceType;
  final int? referenceId;
  final String? data;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationDetail({
    required this.id,
    required this.notificationType,
    required this.title,
    this.titleEn,
    required this.body,
    this.bodyEn,
    this.imageUrl,
    this.referenceType,
    this.referenceId,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationDetail.fromJson(Map<String, dynamic> json) {
    return NotificationDetail(
      id: json['id'] ?? 0,
      notificationType: json['notification_type'] ?? '',
      title: json['title'] ?? '',
      titleEn: json['title_en'],
      body: json['body'] ?? '',
      bodyEn: json['body_en'],
      imageUrl: json['image_url'],
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id'] is int
          ? json['reference_id']
          : int.tryParse(json['reference_id']?.toString() ?? ''),
      data: json['data'] is String ? json['data'] : json['data']?.toString(),
      isRead: json['is_read'] == true,
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
