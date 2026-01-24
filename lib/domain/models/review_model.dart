/// Driver review request model - matches API spec exactly
class CreateDriverReviewRequest {
  final int orderId;
  final int overallRating;
  final String? comment;

  CreateDriverReviewRequest({
    required this.orderId,
    required this.overallRating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'order': orderId,
      'overall_rating': overallRating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }
}

/// Driver review response model - matches API spec exactly
class DriverReview {
  final int orderId;
  final int overallRating;
  final String? comment;

  DriverReview({
    required this.orderId,
    required this.overallRating,
    this.comment,
  });

  factory DriverReview.fromJson(Map<String, dynamic> json) {
    return DriverReview(
      orderId: json['order'] ?? 0,
      overallRating: json['overall_rating'] ?? 0,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': orderId,
      'overall_rating': overallRating,
      if (comment != null) 'comment': comment,
    };
  }
}

/// Restaurant review model (for future use if API is available)
class RestaurantReview {
  final int id;
  final int orderId;
  final int userId;
  final String? userName;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  RestaurantReview({
    required this.id,
    required this.orderId,
    required this.userId,
    this.userName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory RestaurantReview.fromJson(Map<String, dynamic> json) {
    return RestaurantReview(
      id: json['id'] ?? 0,
      orderId: json['order'] ?? 0,
      userId: json['user'] ?? 0,
      userName: json['user_name'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': orderId,
      'user': userId,
      if (userName != null) 'user_name': userName,
      'rating': rating,
      if (comment != null) 'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
