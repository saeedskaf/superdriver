import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:superdriver/domain/models/review_model.dart';
import 'package:superdriver/domain/services/review_services.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  ReviewBloc() : super(const ReviewInitial()) {
    on<DriverReviewSubmitRequested>(_onDriverReviewSubmitRequested);
    on<ReviewReset>(_onReviewReset);
  }

  Future<void> _onDriverReviewSubmitRequested(
    DriverReviewSubmitRequested event,
    Emitter<ReviewState> emit,
  ) async {
    emit(const ReviewSubmitting());
    try {
      final request = CreateDriverReviewRequest(
        orderId: event.orderId,
        overallRating: event.overallRating,
        comment: event.comment,
      );

      final review = await reviewServices.createDriverReview(request);
      emit(ReviewSubmitted(review: review));
    } catch (e) {
      emit(ReviewError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _onReviewReset(ReviewReset event, Emitter<ReviewState> emit) {
    emit(const ReviewInitial());
  }
}
