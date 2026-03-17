import 'package:flutter/material.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_button.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

enum LegalDocumentType { terms, privacy }

Future<void> showLegalDocumentSheet(
  BuildContext context, {
  required LegalDocumentType type,
}) {
  final l10n = AppLocalizations.of(context)!;
  final isTerms = type == LegalDocumentType.terms;

  final title = isTerms ? l10n.termsAndConditions : l10n.privacyPolicy;
  final intro = isTerms ? l10n.legalTermsIntro : l10n.legalPrivacyIntro;

  final sections = isTerms
      ? <_LegalSectionData>[
          _LegalSectionData(
            l10n.legalTermsSectionUseTitle,
            l10n.legalTermsSectionUseBody,
          ),
          _LegalSectionData(
            l10n.legalTermsSectionOrdersTitle,
            l10n.legalTermsSectionOrdersBody,
          ),
          _LegalSectionData(
            l10n.legalTermsSectionPaymentsTitle,
            l10n.legalTermsSectionPaymentsBody,
          ),
          _LegalSectionData(
            l10n.legalTermsSectionUpdatesTitle,
            l10n.legalTermsSectionUpdatesBody,
          ),
        ]
      : <_LegalSectionData>[
          _LegalSectionData(
            l10n.legalPrivacySectionCollectedTitle,
            l10n.legalPrivacySectionCollectedBody,
          ),
          _LegalSectionData(
            l10n.legalPrivacySectionUsageTitle,
            l10n.legalPrivacySectionUsageBody,
          ),
          _LegalSectionData(
            l10n.legalPrivacySectionSharingTitle,
            l10n.legalPrivacySectionSharingBody,
          ),
          _LegalSectionData(
            l10n.legalPrivacySectionSecurityTitle,
            l10n.legalPrivacySectionSecurityBody,
          ),
        ];

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.86,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: ColorsCustom.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: ColorsCustom.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: ColorsCustom.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: ColorsCustom.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: ColorsCustom.primarySoft,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isTerms
                                  ? Icons.description_outlined
                                  : Icons.privacy_tip_outlined,
                              color: ColorsCustom.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextCustom(
                                  text: title,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsCustom.textPrimary,
                                ),
                                const SizedBox(height: 6),
                                TextCustom(
                                  text: l10n.legalLastUpdated,
                                  fontSize: 12,
                                  color: ColorsCustom.textSecondary,
                                ),
                                const SizedBox(height: 10),
                                TextCustom(
                                  text: intro,
                                  fontSize: 13,
                                  color: ColorsCustom.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...sections.map(
                      (section) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _LegalSectionCard(section: section),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ButtonCustom.primary(
                        text: l10n.close,
                        onPressed: () => Navigator.pop(context),
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _LegalSectionData {
  final String title;
  final String body;

  const _LegalSectionData(this.title, this.body);
}

class _LegalSectionCard extends StatelessWidget {
  final _LegalSectionData section;

  const _LegalSectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            text: section.title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ColorsCustom.textPrimary,
          ),
          const SizedBox(height: 6),
          TextCustom(
            text: section.body,
            fontSize: 13,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }
}
