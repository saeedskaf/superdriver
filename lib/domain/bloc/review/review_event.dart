part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Submit driver review - matches API spec
class DriverReviewSubmitRequested extends ReviewEvent {
  final int orderId;
  final int overallRating;
  final String? comment;

  const DriverReviewSubmitRequested({
    required this.orderId,
    required this.overallRating,
    this.comment,
  });

  @override
  List<Object?> get props => [orderId, overallRating, comment];
}

/// Reset review state
class ReviewReset extends ReviewEvent {
  const ReviewReset();
}
