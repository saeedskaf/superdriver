import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/presentation/screens/main/profile/help_center_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/locale/locale_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/domain/services/auth_services.dart';
import 'package:superdriver/domain/services/push_notification_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/change_password_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/edit_profile_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _termsUrl = 'https://superdriverapp.com/terms';
  static const _privacyUrl = 'https://superdriverapp.com/privacy';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadNotificationPref() async {
    final enabled = await pushNotificationService.areNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    if (value) {
      await pushNotificationService.enableNotifications();
    } else {
      await pushNotificationService.disableNotifications();
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _loadProfile() {
    context.read<ProfileBloc>().add(const ProfileLoadRequested());
  }

  String _formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    if (phone.startsWith('0')) {
      final withoutZero = phone.substring(1);
      if (withoutZero.length >= 9) {
        return '+963 ${withoutZero.substring(0, 2)} ${withoutZero.substring(2, 5)} ${withoutZero.substring(5)}';
      }
    }
    return phone;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            _showSnackBar(state.message, isError: true);
          }
        },
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

          if (profileState is ProfileLoading) {
            return _buildLoadingState(l10n);
          }

          if (profileState is ProfileError) {
            return _buildErrorState(l10n, profileState.message);
          }

          return Column(
            children: [
              _buildHeader(l10n, fullName, phoneNumber, initials),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _loadProfile(),
                  color: ColorsCustom.primary,
                  backgroundColor: ColorsCustom.surface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAccountSection(l10n),
                        const SizedBox(height: 14),
                        _buildPreferencesSection(l10n),
                        const SizedBox(height: 14),
                        _buildSupportSection(l10n),
                        const SizedBox(height: 14),
                        _buildLogoutButton(l10n),
                        const SizedBox(height: 12),
                        _buildDeleteAccountButton(l10n),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ──

  Widget _buildHeader(
    AppLocalizations l10n,
    String fullName,
    String phoneNumber,
    String initials,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 16,
        24,
        24,
      ),
      decoration: const BoxDecoration(color: ColorsCustom.surface),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/icons/profile_placeholder.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      text: l10n.profile,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    TextCustom(
                      text: l10n.manageYourAccount,
                      fontSize: 13,
                      color: ColorsCustom.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: ColorsCustom.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ColorsCustom.secondaryDark.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: ColorsCustom.secondaryDark.withAlpha(36),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ColorsCustom.secondaryDark.withAlpha(51),
                    ),
                  ),
                  child: Center(
                    child: TextCustom(
                      text: initials,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.secondaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        text: fullName,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorsCustom.textPrimary,
                      ),
                      if (phoneNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_rounded,
                              size: 14,
                              color: ColorsCustom.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            TextCustom(
                              text: _formatPhoneNumber(phoneNumber),
                              fontSize: 13,
                              color: ColorsCustom.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _navigateToEditProfile(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColorsCustom.secondaryDark.withAlpha(36),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: ColorsCustom.secondaryDark,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Sections ──

  Widget _buildAccountSection(AppLocalizations l10n) {
    return _MenuSection(
      title: l10n.accountSection,
      items: [
        _MenuItem(
          icon: Icons.person_outline_rounded,
          title: l10n.personalInfo,
          onTap: () => _navigateToEditProfile(context),
        ),
        _MenuItem(
          icon: Icons.lock_outline_rounded,
          title: l10n.changePassword,
          onTap: () => _navigateToChangePassword(context),
        ),
        _MenuItem(
          icon: Icons.location_on_outlined,
          title: l10n.addresses,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressesScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(AppLocalizations l10n) {
    return _MenuSection(
      title: l10n.preferencesSection,
      items: [
        _MenuItem(
          icon: Icons.language_rounded,
          title: l10n.language,
          trailing: l10n.currentLanguage,
          onTap: () => _showLanguageDialog(context, l10n),
        ),
        _MenuItem(
          icon: Icons.notifications_outlined,
          title: l10n.pushNotifications,
          onTap: () => _toggleNotifications(!_notificationsEnabled),
          customTrailing: Switch.adaptive(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeColor: ColorsCustom.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportSection(AppLocalizations l10n) {
    return _MenuSection(
      title: l10n.supportSection,
      items: [
        _MenuItem(
          icon: Icons.help_outline_rounded,
          title: l10n.helpCenter,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpCenterScreen()),
          ),
        ),
        _MenuItem(
          icon: Icons.description_outlined,
          title: l10n.termsAndConditions,
          onTap: () => _launchUrl(_termsUrl),
        ),
        _MenuItem(
          icon: Icons.privacy_tip_outlined,
          title: l10n.privacyPolicy,
          onTap: () => _launchUrl(_privacyUrl),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context, l10n),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: ColorsCustom.errorBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.error.withAlpha(77)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.logout_rounded,
                color: ColorsCustom.error,
                size: 20,
              ),
              const SizedBox(width: 10),
              TextCustom(
                text: l10n.logout,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showDeleteAccountDialog(context),
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.error.withAlpha(50)),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  color: ColorsCustom.error.withAlpha(180),
                  size: 20,
                ),
                const SizedBox(width: 10),
                TextCustom(
                  text: l10n.deleteAccount,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ColorsCustom.error.withAlpha(180),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── States ──

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
          const SizedBox(height: 16),
          TextCustom(
            text: l10n.loading,
            fontSize: 15,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: ColorsCustom.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: ColorsCustom.error,
              ),
            ),
            const SizedBox(height: 24),
            TextCustom(
              text: l10n.errorOccurred,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: message,
              fontSize: 14,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ButtonCustom.primary(text: l10n.retry, onPressed: _loadProfile),
            const SizedBox(height: 12),
            ButtonCustom.secondary(
              text: l10n.logout,
              onPressed: () => _showLogoutDialog(context, l10n),
            ),
          ],
        ),
      ),
    );
  }

  // ── Navigation ──

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
    if (mounted) _loadProfile();
  }

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
    if (mounted) _loadProfile();
  }

  // ── Dialogs ──

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
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
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: ColorsCustom.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: ColorsCustom.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              TextCustom(
                text: l10n.logout,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              TextCustom(
                text: l10n.logoutConfirmation,
                fontSize: 14,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ButtonCustom.primary(
                text: l10n.logout,
                onPressed: () async {
                  Navigator.pop(ctx);
                  await pushNotificationService.unregisterDeviceToken();
                  if (!context.mounted) return;
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
              ButtonCustom.secondary(
                text: l10n.cancel,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DeleteAccountDialog(
        onDeleted: () async {
          Navigator.pop(ctx);
          await pushNotificationService.unregisterDeviceToken();
          if (!context.mounted) return;
          context.read<AuthBloc>().add(const AuthLogoutRequested());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppLocalizations l10n) {
    final localeBloc = context.read<LocaleBloc>();

    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<LocaleBloc, LocaleState>(
        bloc: localeBloc,
        builder: (context, state) {
          return AlertDialog(
            backgroundColor: ColorsCustom.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: EdgeInsets.zero,
            content: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: ColorsCustom.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: ColorsCustom.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextCustom(
                    text: l10n.selectLanguage,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                  const SizedBox(height: 20),
                  _LanguageOption(
                    title: 'العربية',
                    subtitle: 'Arabic',
                    isSelected: state.isArabic,
                    onTap: () {
                      localeBloc.add(const LocaleSetArabic());
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 10),
                  _LanguageOption(
                    title: 'English',
                    subtitle: 'الإنجليزية',
                    isSelected: state.isEnglish,
                    onTap: () {
                      localeBloc.add(const LocaleSetEnglish());
                      Navigator.pop(ctx);
                    },
                  ),
                  const SizedBox(height: 20),
                  ButtonCustom.secondary(
                    text: l10n.cancel,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================
// DELETE ACCOUNT DIALOG
// ============================================

class _DeleteAccountDialog extends StatefulWidget {
  final VoidCallback onDeleted;

  const _DeleteAccountDialog({required this.onDeleted});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _error = l10n.deleteAccountPasswordRequired;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();

    try {
      await authServices.deleteAccount(password: password, reason: reason);

      if (!mounted) return;
      widget.onDeleted();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: ColorsCustom.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: ColorsCustom.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: ColorsCustom.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              TextCustom(
                text: l10n.deleteAccount,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Description
              TextCustom(
                text: l10n.deleteAccountDescription,
                fontSize: 13,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Password field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: l10n.deleteAccountPasswordHint,
                  hintStyle: const TextStyle(
                    color: ColorsCustom.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: ColorsCustom.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: ColorsCustom.textSecondary,
                      size: 20,
                    ),
                  ),
                  filled: true,
                  fillColor: ColorsCustom.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ColorsCustom.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ColorsCustom.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorsCustom.error,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Reason field (optional)
              TextFormField(
                controller: _reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: l10n.deleteAccountReasonHint,
                  hintStyle: const TextStyle(
                    color: ColorsCustom.textHint,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: ColorsCustom.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ColorsCustom.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: ColorsCustom.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: ColorsCustom.error,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorsCustom.errorBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextCustom(
                    text: _error!,
                    fontSize: 13,
                    color: ColorsCustom.error,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Delete button
              _isLoading
                  ? const SizedBox(
                      height: 48,
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: ColorsCustom.error,
                          ),
                        ),
                      ),
                    )
                  : ButtonCustom.primary(
                      text: l10n.deleteAccountConfirm,
                      onPressed: _deleteAccount,
                    ),
              const SizedBox(height: 10),

              // Cancel button
              if (!_isLoading)
                ButtonCustom.secondary(
                  text: l10n.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// MENU SECTION
// ============================================

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextCustom(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textSecondary,
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == items.length - 1;

            return Column(
              children: [
                GestureDetector(
                  onTap: item.onTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ColorsCustom.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            size: 20,
                            color: ColorsCustom.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextCustom(
                            text: item.title,
                            fontSize: 15,
                            color: ColorsCustom.textPrimary,
                          ),
                        ),
                        if (item.trailing != null) ...[
                          TextCustom(
                            text: item.trailing!,
                            fontSize: 13,
                            color: ColorsCustom.textSecondary,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.customTrailing != null)
                          item.customTrailing!
                        else
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: ColorsCustom.textHint,
                          ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.only(left: 70),
                    child: Divider(color: ColorsCustom.border, height: 1),
                  ),
              ],
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? trailing;
  final Widget? customTrailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.customTrailing,
    required this.onTap,
  });
}

// ============================================
// LANGUAGE OPTION
// ============================================

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsCustom.primarySoft
              : ColorsCustom.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorsCustom.primary : ColorsCustom.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsCustom.primary.withAlpha(26)
                    : ColorsCustom.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.language_rounded,
                size: 20,
                color: isSelected
                    ? ColorsCustom.primary
                    : ColorsCustom.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: title,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: ColorsCustom.textPrimary,
                  ),
                  TextCustom(
                    text: subtitle,
                    fontSize: 12,
                    color: ColorsCustom.textSecondary,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: ColorsCustom.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
