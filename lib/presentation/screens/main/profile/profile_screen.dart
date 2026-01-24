import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/locale/locale_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/change_password_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      final withoutZero = phone.substring(1);
      if (withoutZero.length >= 9) {
        return '+963 ${withoutZero.substring(0, 2)} ${withoutZero.substring(2, 5)} ${withoutZero.substring(5)}';
      }
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          String fullName = l10n.defaultUserName;
          String phoneNumber = '';
          String initials = l10n.defaultUserInitial;

          if (profileState is ProfileLoaded) {
            fullName = profileState.fullName.isEmpty
                ? l10n.defaultUserName
                : profileState.fullName;
            phoneNumber = profileState.phoneNumber;
            initials = profileState.initials.isEmpty
                ? l10n.defaultUserInitial
                : profileState.initials;
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
              },
              color: const Color(0xFFD32F2F),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Header with Profile Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(color: Colors.white),
                      child: Column(
                        children: [
                          // Avatar with initials
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: TextCustom(
                                text: initials,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD32F2F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // User name
                          TextCustom(
                            text: fullName,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 4),
                          // Phone number
                          if (phoneNumber.isNotEmpty)
                            TextCustom(
                              text: _formatPhoneNumber(phoneNumber),
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Account Section
                    _buildMenuSection(
                      title: l10n.accountSection,
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: l10n.personalInfo,
                          onTap: () => _navigateToEditProfile(context),
                        ),
                        _MenuItem(
                          icon: Icons.security_outlined,
                          title: l10n.changePassword,
                          onTap: () => _navigateToChangePassword(context),
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: l10n.addresses,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressesScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Preferences Section
                    _buildMenuSection(
                      title: l10n.preferencesSection,
                      items: [
                        _MenuItem(
                          icon: Icons.language_outlined,
                          title: l10n.language,
                          trailing: l10n.currentLanguage,
                          onTap: () {
                            _showLanguageDialog(context, l10n);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Support Section
                    _buildMenuSection(
                      title: l10n.supportSection,
                      items: [
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: l10n.helpCenter,
                          onTap: () {
                            // TODO: Help center
                          },
                        ),
                        _MenuItem(
                          icon: Icons.description_outlined,
                          title: l10n.termsAndConditions,
                          onTap: () {
                            // TODO: Terms and conditions
                          },
                        ),
                        _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: l10n.privacyPolicy,
                          onTap: () {
                            // TODO: Privacy policy
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            _showLogoutDialog(context, l10n);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout,
                                color: Colors.red.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              TextCustom(
                                text: l10n.logout,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Navigate to edit profile and refresh data on return
  void _navigateToEditProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const EditProfileScreen(),
        ),
      ),
    );

    if (!context.mounted) return;

    // Refresh profile data when returning
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  /// Navigate to change password
  void _navigateToChangePassword(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const ChangePasswordScreen(),
        ),
      ),
    );

    if (!context.mounted) return;

    // Refresh profile data when returning (in case state needs reset)
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextCustom(
              text: title,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextCustom(
                            text: item.title,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        if (item.trailing != null)
                          TextCustom(
                            text: item.trailing!,
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.only(right: 72),
                    child: Container(height: 1, color: Colors.grey.shade100),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: TextCustom(
          text: l10n.logout,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        content: TextCustom(
          text: l10n.logoutConfirmation,
          fontSize: 15,
          color: Colors.grey.shade700,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextCustom(
              text: l10n.cancel,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: TextCustom(
              text: l10n.logout,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final localeBloc = context.read<LocaleBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<LocaleBloc, LocaleState>(
        bloc: localeBloc,
        builder: (context, state) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: TextCustom(
              text: l10n.selectLanguage,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arabic Option
                _buildLanguageOption(
                  context: context,
                  dialogContext: dialogContext,
                  title: 'العربية',
                  subtitle: 'Arabic',
                  isSelected: state.isArabic,
                  onTap: () {
                    localeBloc.add(const LocaleSetArabic());
                    Navigator.pop(dialogContext);
                  },
                ),
                const SizedBox(height: 12),
                // English Option
                _buildLanguageOption(
                  context: context,
                  dialogContext: dialogContext,
                  title: 'English',
                  subtitle: 'الإنجليزية',
                  isSelected: state.isEnglish,
                  onTap: () {
                    localeBloc.add(const LocaleSetEnglish());
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: TextCustom(
                  text: l10n.cancel,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required BuildContext dialogContext,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD32F2F).withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFD32F2F), width: 2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD32F2F).withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.language,
                size: 20,
                color: isSelected
                    ? const Color(0xFFD32F2F)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  TextCustom(
                    text: subtitle,
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFD32F2F),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
}
