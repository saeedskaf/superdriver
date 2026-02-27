import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  static const _email = 'info@superdriverapp.com';
  static const _phoneNumber = '+963934082422';

  int? _expandedCategoryIndex;
  int? _expandedQuestionIndex;

  // ============================================================
  // FAQ DATA
  // ============================================================

  List<_FaqCategory> _buildFaqData(AppLocalizations l10n) {
    return [
      _FaqCategory(
        icon: Icons.shopping_bag_outlined,
        title: l10n.helpOrdersTitle,
        color: ColorsCustom.primary,
        questions: [
          _FaqItem(q: l10n.helpQ1, a: l10n.helpA1),
          _FaqItem(q: l10n.helpQ1_1, a: l10n.helpA1_1),
          _FaqItem(q: l10n.helpQ2, a: l10n.helpA2),
          _FaqItem(q: l10n.helpQ3, a: l10n.helpA3),
        ],
      ),
      _FaqCategory(
        icon: Icons.chat_outlined,
        title: l10n.helpChatTitle,
        color: const Color(0xFF7B1FA2),
        questions: [
          _FaqItem(q: l10n.helpQ10, a: l10n.helpA10),
          _FaqItem(q: l10n.helpQ11, a: l10n.helpA11),
          _FaqItem(q: l10n.helpQ12, a: l10n.helpA12),
          _FaqItem(q: l10n.helpQ13, a: l10n.helpA13),
        ],
      ),
      _FaqCategory(
        icon: Icons.delivery_dining_rounded,
        title: l10n.helpDeliveryTitle,
        color: const Color(0xFF1976D2),
        questions: [
          _FaqItem(q: l10n.helpQ4, a: l10n.helpA4),
          _FaqItem(q: l10n.helpQ5, a: l10n.helpA5),
        ],
      ),
      _FaqCategory(
        icon: Icons.payment_outlined,
        title: l10n.helpPaymentTitle,
        color: const Color(0xFF388E3C),
        questions: [
          _FaqItem(q: l10n.helpQ6, a: l10n.helpA6),
          _FaqItem(q: l10n.helpQ7, a: l10n.helpA7),
        ],
      ),
      _FaqCategory(
        icon: Icons.person_outline_rounded,
        title: l10n.helpAccountTitle,
        color: const Color(0xFFB8902E),
        questions: [
          _FaqItem(q: l10n.helpQ8, a: l10n.helpA8),
          _FaqItem(q: l10n.helpQ9, a: l10n.helpA9),
        ],
      ),
    ];
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Future<void> _sendEmail() async {
    final uri = Uri(scheme: 'mailto', path: _email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/$_phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall() async {
    final uri = Uri(scheme: 'tel', path: _phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: _email));
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.emailCopied),
        backgroundColor: ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _copyPhone() {
    Clipboard.setData(const ClipboardData(text: _phoneNumber));
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.phoneCopied),
        backgroundColor: ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleCategory(int index) {
    setState(() {
      if (_expandedCategoryIndex == index) {
        _expandedCategoryIndex = null;
        _expandedQuestionIndex = null;
      } else {
        _expandedCategoryIndex = index;
        _expandedQuestionIndex = null;
      }
    });
  }

  void _toggleQuestion(int index) {
    setState(() {
      _expandedQuestionIndex = _expandedQuestionIndex == index ? null : index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final faqData = _buildFaqData(l10n);

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: AppBar(
        backgroundColor: ColorsCustom.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorsCustom.primary,
              ),
            ),
          ),
        ),
        title: TextCustom(
          text: l10n.helpCenter,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          // ── Header card ──
          _buildHeaderCard(l10n),
          const SizedBox(height: 24),

          // ── FAQ Section Title ──
          TextCustom(
            text: l10n.frequentlyAskedQuestions,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 14),

          // ── FAQ Categories ──
          ...List.generate(faqData.length, (i) {
            final cat = faqData[i];
            final isExpanded = _expandedCategoryIndex == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCategoryCard(cat, i, isExpanded),
            );
          }),

          const SizedBox(height: 24),

          // ── Contact Section ──
          _buildContactSection(l10n),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CARD
  // ============================================================

  Widget _buildHeaderCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ColorsCustom.primary, ColorsCustom.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorsCustom.primary.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                'assets/icons/help_illustration.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.helpHeaderTitle,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextCustom(
            text: l10n.helpHeaderSubtitle,
            fontSize: 16,
            color: Colors.white.withAlpha(200),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAQ CATEGORY CARD
  // ============================================================

  Widget _buildCategoryCard(_FaqCategory cat, int index, bool isExpanded) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? cat.color.withAlpha(77) : ColorsCustom.border,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: cat.color.withAlpha(20),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // ── Category header ──
          InkWell(
            onTap: () => _toggleCategory(index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cat.color.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(cat.icon, color: cat.color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextCustom(
                      text: cat.title,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ColorsCustom.textPrimary,
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isExpanded ? cat.color : ColorsCustom.textHint,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Questions list ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildQuestionsList(cat),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList(_FaqCategory cat) {
    return Column(
      children: [
        const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: ColorsCustom.border,
        ),
        ...List.generate(cat.questions.length, (i) {
          final q = cat.questions[i];
          final isOpen = _expandedQuestionIndex == i;
          return Column(
            children: [
              InkWell(
                onTap: () => _toggleQuestion(i),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isOpen
                              ? Icons.remove_circle_outline_rounded
                              : Icons.add_circle_outline_rounded,
                          color: isOpen ? cat.color : ColorsCustom.textHint,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextCustom(
                              text: q.q,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isOpen
                                  ? cat.color
                                  : ColorsCustom.textPrimary,
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextCustom(
                                  text: q.a,
                                  fontSize: 13,
                                  color: ColorsCustom.textSecondary,
                                ),
                              ),
                              crossFadeState: isOpen
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 200),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (i < cat.questions.length - 1)
                const Divider(
                  height: 1,
                  indent: 52,
                  endIndent: 16,
                  color: ColorsCustom.border,
                ),
            ],
          );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  // ============================================================
  // CONTACT SECTION
  // ============================================================

  Widget _buildContactSection(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ColorsCustom.warningBg,
              shape: BoxShape.circle,
              border: Border.all(color: ColorsCustom.warning.withAlpha(50)),
            ),
            child: const Icon(
              Icons.headset_mic_rounded,
              color: ColorsCustom.warning,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          TextCustom(
            text: l10n.contactUsTitle,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: l10n.contactUsSubtitle,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // ── Phone row ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorsCustom.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.phone_rounded,
                  color: ColorsCustom.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: const SelectableText(
                      _phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _copyPhone,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorsCustom.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: ColorsCustom.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── WhatsApp & Call buttons ──
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: TextCustom(
                    text: l10n.whatsapp,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _makePhoneCall,
                  icon: const Icon(Icons.phone_rounded, size: 18),
                  label: TextCustom(
                    text: l10n.call,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorsCustom.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: ColorsCustom.border),
          const SizedBox(height: 16),

          // ── Email row ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: ColorsCustom.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.alternate_email_rounded,
                  color: ColorsCustom.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: const SelectableText(
                      _email,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ColorsCustom.textPrimary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _copyEmail,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorsCustom.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: ColorsCustom.primary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Send email button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: TextCustom(
                text: l10n.sendEmail,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsCustom.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _FaqCategory {
  final IconData icon;
  final String title;
  final Color color;
  final List<_FaqItem> questions;

  const _FaqCategory({
    required this.icon,
    required this.title,
    required this.color,
    required this.questions,
  });
}

class _FaqItem {
  final String q;
  final String a;

  const _FaqItem({required this.q, required this.a});
}
