import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/review/review_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class DriverReviewScreen extends StatefulWidget {
  final int orderId;
  final String? driverName;

  const DriverReviewScreen({super.key, required this.orderId, this.driverName});

  @override
  State<DriverReviewScreen> createState() => _DriverReviewScreenState();
}

class _DriverReviewScreenState extends State<DriverReviewScreen> {
  int _overallRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isValid => _overallRating > 0;

  void _submitReview() {
    if (!_isValid) return;

    context.read<ReviewBloc>().add(
      DriverReviewSubmitRequested(
        orderId: widget.orderId,
        overallRating: _overallRating,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitted) {
          _showSuccessDialog(context, l10n);
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: ColorsCustom.background,
        appBar: _buildAppBar(context, l10n),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDriverCard(context, l10n),
              const SizedBox(height: 32),

              _buildRatingSection(
                title: l10n.overallRating,
                subtitle: l10n.rateYourExperience,
                rating: _overallRating,
                onChanged: (rating) => setState(() => _overallRating = rating),
              ),
              const SizedBox(height: 24),

              _buildCommentField(l10n),
              const SizedBox(height: 32),

              _buildSubmitButton(context, l10n),
              const SizedBox(height: 16),

              _buildSkipButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ColorsCustom.grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 20,
            color: ColorsCustom.textPrimary,
          ),
        ),
      ),
      title: TextCustom(
        text: l10n.rateDriver,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
    );
  }

  Widget _buildDriverCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsCustom.primary.withOpacity(0.1),
            ColorsCustom.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.delivery_dining_rounded,
              size: 40,
              color: Colors.blue.shade600,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: widget.driverName ?? l10n.driver,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 6),
                TextCustom(
                  text: '${l10n.orderNumber}: #${widget.orderId}',
                  fontSize: 14,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required int rating,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: subtitle,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => onChanged(starIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    starIndex <= rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 50,
                    color: starIndex <= rating
                        ? Colors.amber.shade500
                        : ColorsCustom.grey300,
                  ),
                ),
              );
            }),
          ),
          if (rating > 0) ...[
            const SizedBox(height: 16),
            Center(
              child: TextCustom(
                text: _getRatingText(rating, context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(rating),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getRatingText(int rating, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (rating) {
      case 1:
        return l10n.veryPoor;
      case 2:
        return l10n.poor;
      case 3:
        return l10n.average;
      case 4:
        return l10n.good;
      case 5:
        return l10n.excellent;
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red.shade600;
      case 3:
        return Colors.orange.shade600;
      case 4:
      case 5:
        return Colors.green.shade600;
      default:
        return ColorsCustom.textSecondary;
    }
  }

  Widget _buildCommentField(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: ColorsCustom.primary,
                size: 26,
              ),
              const SizedBox(width: 10),
              TextCustom(
                text: l10n.addComment,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: l10n.optional,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 5,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: l10n.shareYourThoughts,
              hintStyle: TextStyle(color: ColorsCustom.textSecondary),
              filled: true,
              fillColor: ColorsCustom.grey100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final isLoading = state is ReviewSubmitting;

        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (_isValid && !isLoading) ? _submitReview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsCustom.primary,
              disabledBackgroundColor: ColorsCustom.grey300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: ColorsCustom.primary.withOpacity(0.3),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      TextCustom(
                        text: l10n.submitReview,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildSkipButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => Navigator.pop(context),
        child: TextCustom(
          text: l10n.skip,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ColorsCustom.textSecondary,
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_rounded,
                size: 55,
                color: Colors.green.shade500,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.reviewSubmitted,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextCustom(
              text: l10n.thankYouForReview,
              fontSize: 15,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsCustom.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: TextCustom(
                  text: l10n.done,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
