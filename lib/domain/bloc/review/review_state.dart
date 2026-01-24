part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

class ReviewSubmitted extends ReviewState {
  final DriverReview review;

  const ReviewSubmitted({required this.review});

  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
