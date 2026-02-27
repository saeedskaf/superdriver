import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/review/review_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
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

  void _showSnackBar(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsCustom.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
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
          _showSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: ColorsCustom.background,
        appBar: _buildAppBar(l10n),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDriverCard(l10n),
              const SizedBox(height: 28),
              _buildRatingCard(l10n),
              const SizedBox(height: 20),
              _buildCommentCard(l10n),
              const SizedBox(height: 28),
              _buildSubmitButton(l10n),
              const SizedBox(height: 12),
              _buildSkipButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  // ── AppBar ──

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.close_rounded,
              size: 20,
              color: ColorsCustom.primary,
            ),
          ),
        ),
      ),
      title: TextCustom(
        text: l10n.rateDriver,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: ColorsCustom.textPrimary,
      ),
      centerTitle: true,
    );
  }

  // ── Driver Card ──

  Widget _buildDriverCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorsCustom.primary.withAlpha(51)),
            ),
            child: Image.asset('assets/icons/driver_illustration.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  text: widget.driverName != null
                      ? '${l10n.driver} ${widget.driverName}'
                      : l10n.driver,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.textPrimary,
                ),
                const SizedBox(height: 4),
                TextCustom(
                  text: '${l10n.orderNumber}: #${widget.orderId}',
                  fontSize: 13,
                  color: ColorsCustom.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Rating Card ──

  Widget _buildRatingCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: l10n.overallRating,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 4),
          TextCustom(
            text: l10n.rateYourExperience,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _overallRating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    starIndex <= _overallRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 48,
                    color: starIndex <= _overallRating
                        ? ColorsCustom.warning
                        : ColorsCustom.border,
                  ),
                ),
              );
            }),
          ),
          if (_overallRating > 0) ...[
            const SizedBox(height: 14),
            Center(
              child: TextCustom(
                text: _getRatingText(_overallRating, context),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _getRatingColor(_overallRating),
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
        return ColorsCustom.error;
      case 3:
        return ColorsCustom.warning;
      case 4:
      case 5:
        return ColorsCustom.success;
      default:
        return ColorsCustom.textSecondary;
    }
  }

  // ── Comment Card ──

  Widget _buildCommentCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: ColorsCustom.primary,
                size: 24,
              ),
              const SizedBox(width: 10),
              TextCustom(
                text: l10n.addComment,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextCustom(
            text: l10n.optional,
            fontSize: 12,
            color: ColorsCustom.textSecondary,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _commentController,
            maxLines: 4,
            maxLength: 500,
            style: const TextStyle(
              fontSize: 14,
              color: ColorsCustom.textPrimary,
              fontFamily: 'Cairo',
            ),
            decoration: InputDecoration(
              hintText: l10n.shareYourThoughts,
              hintStyle: const TextStyle(
                color: ColorsCustom.textHint,
                fontSize: 13,
                fontFamily: 'Cairo',
              ),
              filled: true,
              fillColor: ColorsCustom.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Submit Button ──

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final isLoading = state is ReviewSubmitting;

        return ButtonCustom.primary(
          text: l10n.submitReview,
          onPressed: (_isValid && !isLoading) ? _submitReview : null,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ColorsCustom.textOnPrimary,
                    ),
                  ),
                )
              : const Icon(
                  Icons.check_circle_rounded,
                  color: ColorsCustom.textOnPrimary,
                  size: 20,
                ),
        );
      },
    );
  }

  // ── Skip Button ──

  Widget _buildSkipButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: TextCustom(
              text: l10n.skip,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ── Success Dialog ──

  void _showSuccessDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ColorsCustom.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: ColorsCustom.successBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: ColorsCustom.success,
                ),
              ),
              const SizedBox(height: 20),
              TextCustom(
                text: l10n.reviewSubmitted,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextCustom(
                text: l10n.thankYouForReview,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ButtonCustom.primary(
                text: l10n.done,
                onPressed: () {
                  Navigator.pop(ctx); // close dialog
                  Navigator.pop(context); // back to order details
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
