import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/presentation/screens/main/profile/help_center_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/domain/bloc/locale/locale_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/data/services/auth_service.dart';
import 'package:superdriver/data/services/push_notification_service.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/custom_text.dart';
import 'package:superdriver/presentation/components/custom_button.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/addresses_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/change_password_screen.dart';
import 'package:superdriver/presentation/screens/main/profile/edit_profile_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const _kTermsUrl = 'https://superdriverapp.com/terms';
const _kPrivacyUrl = 'https://superdriverapp.com/privacy';

// ─── ProfileScreen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadNotificationPref();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  // ── Data helpers ───────────────────────────────────────────────────────────

  void _loadProfile() =>
      context.read<ProfileBloc>().add(const ProfileLoadRequested());

  Future<void> _loadNotificationPref() async {
    final enabled = await pushNotificationService.areNotificationsEnabled();
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    value
        ? await pushNotificationService.enableNotifications()
        : await pushNotificationService.disableNotifications();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  Future<void> _navigateToEditProfile() async {
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

  Future<void> _navigateToChangePassword() async {
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

  void _pushScreen(Widget screen) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

  // ── UI helpers ─────────────────────────────────────────────────────────────

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? ColorsCustom.error : ColorsCustom.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showLogoutDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        icon: Icons.logout_rounded,
        iconColor: ColorsCustom.error,
        iconBg: ColorsCustom.errorBg,
        title: l10n.logout,
        description: l10n.logoutConfirmation,
        confirmText: l10n.logout,
        cancelText: l10n.cancel,
        onConfirm: () async {
          Navigator.pop(ctx);
          if (!context.mounted) return;
          context.read<AuthBloc>().add(const AuthLogoutRequested());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _DeleteAccountDialog(
        onDeleted: () {
          Navigator.pop(ctx);
          if (!context.mounted) return;
          context.read<AuthBloc>().add(const AuthLogoutRequested());
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (_) => false,
          );
        },
      ),
    );
  }

  void _showLanguageDialog(AppLocalizations l10n) {
    final localeBloc = context.read<LocaleBloc>();
    showDialog(
      context: context,
      builder: (ctx) => BlocBuilder<LocaleBloc, LocaleState>(
        bloc: localeBloc,
        builder: (_, state) => _LanguageDialog(
          l10n: l10n,
          isArabic: state.isArabic,
          onSelectArabic: () {
            localeBloc.add(const LocaleSetArabic());
            Navigator.pop(ctx);
          },
          onSelectEnglish: () {
            localeBloc.add(const LocaleSetEnglish());
            Navigator.pop(ctx);
          },
          onCancel: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.background,
      appBar: _ProfileHeader(l10n: l10n),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (_, state) {
          if (state is ProfileError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (_, state) {
          if (state is ProfileLoading) return _LoadingView(l10n: l10n);
          if (state is ProfileError) {
            return _ErrorView(
              l10n: l10n,
              message: state.message,
              onRetry: _loadProfile,
              onLogout: () => _showLogoutDialog(l10n),
            );
          }

          final loaded = state is ProfileLoaded ? state : null;
          final fullName = loaded?.fullName.isEmpty ?? true
              ? l10n.defaultUserName
              : loaded!.fullName;
          final phone = loaded?.phoneNumber ?? '';
          final initials = loaded?.initials.isEmpty ?? true
              ? l10n.defaultUserInitial
              : loaded!.initials;

          return RefreshIndicator(
            onRefresh: () async => _loadProfile(),
            color: ColorsCustom.primary,
            backgroundColor: ColorsCustom.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 125),
              child: Column(
                children: [
                  _UserCard(
                    fullName: fullName,
                    phoneNumber: phone,
                    initials: initials,
                    notificationsEnabled: _notificationsEnabled,
                    currentLanguage: l10n.currentLanguage,
                    notificationsLabel: l10n.notifications,
                    manageAccountLabel: l10n.manageYourAccount,
                    onDeleteTap: _showDeleteAccountDialog,
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: l10n.accountSection,
                    icon: Icons.manage_accounts_rounded,
                    accentColor: ColorsCustom.primary,
                    items: [
                      _MenuItemData(
                        icon: Icons.person_outline_rounded,
                        title: l10n.personalInfo,
                        accentColor: ColorsCustom.primary,
                        onTap: _navigateToEditProfile,
                      ),
                      _MenuItemData(
                        icon: Icons.lock_outline_rounded,
                        title: l10n.changePassword,
                        accentColor: ColorsCustom.primary,
                        onTap: _navigateToChangePassword,
                      ),
                      _MenuItemData(
                        icon: Icons.location_on_outlined,
                        title: l10n.addresses,
                        accentColor: ColorsCustom.primary,
                        onTap: () => _pushScreen(const AddressesScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: l10n.preferencesSection,
                    icon: Icons.tune_rounded,
                    accentColor: ColorsCustom.primary,
                    items: [
                      _MenuItemData(
                        icon: Icons.language_rounded,
                        title: l10n.language,
                        trailing: l10n.currentLanguage,
                        accentColor: ColorsCustom.primary,
                        onTap: () => _showLanguageDialog(l10n),
                      ),
                      _MenuItemData(
                        icon: Icons.notifications_outlined,
                        title: l10n.pushNotifications,
                        accentColor: ColorsCustom.primary,
                        onTap: () =>
                            _toggleNotifications(!_notificationsEnabled),
                        customTrailing: Switch.adaptive(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeThumbColor: ColorsCustom.primary,
                          activeTrackColor: ColorsCustom.primary.withAlpha(90),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _MenuSection(
                    title: l10n.supportSection,
                    icon: Icons.support_agent_rounded,
                    accentColor: ColorsCustom.primary,
                    items: [
                      _MenuItemData(
                        icon: Icons.help_outline_rounded,
                        title: l10n.helpCenter,
                        accentColor: ColorsCustom.primary,
                        onTap: () => _pushScreen(const HelpCenterScreen()),
                      ),
                      _MenuItemData(
                        icon: Icons.description_outlined,
                        title: l10n.termsAndConditions,
                        accentColor: ColorsCustom.primary,
                        onTap: () => _launchUrl(_kTermsUrl),
                      ),
                      _MenuItemData(
                        icon: Icons.privacy_tip_outlined,
                        title: l10n.privacyPolicy,
                        accentColor: ColorsCustom.primary,
                        onTap: () => _launchUrl(_kPrivacyUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _LogoutButton(
                    label: l10n.logout,
                    onTap: () => _showLogoutDialog(l10n),
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

// ─── Header ───────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget implements PreferredSizeWidget {
  const _ProfileHeader({required this.l10n});

  final AppLocalizations l10n;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorsCustom.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(color: ColorsCustom.surface),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              child: Image.asset(
                'assets/icons/profile_placeholder.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            TextCustom(
              text: l10n.profile,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.fullName,
    required this.phoneNumber,
    required this.initials,
    required this.notificationsEnabled,
    required this.currentLanguage,
    required this.notificationsLabel,
    required this.manageAccountLabel,
    required this.onDeleteTap,
  });

  final String fullName;
  final String phoneNumber;
  final String initials;
  final bool notificationsEnabled;
  final String currentLanguage;
  final String notificationsLabel;
  final String manageAccountLabel;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ColorsCustom.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _InitialsAvatar(initials: initials),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      text: fullName,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorsCustom.textPrimary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    TextCustom(
                      text: manageAccountLabel,
                      fontSize: 13,
                      color: ColorsCustom.textSecondary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _DeleteIconButton(onTap: onDeleteTap),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (phoneNumber.isNotEmpty)
                _InfoTag(
                  icon: Icons.phone_rounded,
                  label: phoneNumber,
                  bg: ColorsCustom.warningBg,
                  fg: ColorsCustom.secondaryDark,
                ),
              _InfoTag(
                icon: Icons.language_rounded,
                label: currentLanguage,
                bg: ColorsCustom.warningBg,
                fg: ColorsCustom.secondaryDark,
              ),
              _InfoTag(
                icon: notificationsEnabled
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                label: notificationsLabel,
                bg: ColorsCustom.warningBg,
                fg: ColorsCustom.secondaryDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: ColorsCustom.warningBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorsCustom.secondaryDark.withAlpha(40)),
      ),
      child: Center(
        child: TextCustom(
          text: initials,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.secondaryDark,
        ),
      ),
    );
  }
}

class _DeleteIconButton extends StatelessWidget {
  const _DeleteIconButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorsCustom.errorBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorsCustom.error.withAlpha(24)),
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: ColorsCustom.error,
          size: 18,
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: TextCustom(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────────────────────

class _MenuItemData {
  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.onTap,
    this.trailing,
    this.customTrailing,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final String? trailing;
  final Widget? customTrailing;
  final VoidCallback onTap;
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final List<_MenuItemData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: const BorderRadius.all(Radius.circular(22)),
        border: Border.all(color: ColorsCustom.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: icon, accentColor: accentColor),
          for (int i = 0; i < items.length; i++) ...[
            _MenuRow(item: items[i]),
            if (i < items.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 70),
                child: Divider(color: ColorsCustom.border, height: 1),
              ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ColorsCustom.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: accentColor),
          ),
          const SizedBox(width: 10),
          TextCustom(
            text: title,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final _MenuItemData item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(item.icon, size: 19, color: item.accentColor),
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
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: ColorsCustom.background,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: ColorsCustom.textHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.error.withAlpha(50)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(7),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: ColorsCustom.errorBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: ColorsCustom.error,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              TextCustom(
                text: label,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loading / Error Views ────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
            ),
          ),
          const SizedBox(height: 14),
          TextCustom(
            text: l10n.loading,
            fontSize: 14,
            color: ColorsCustom.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.l10n,
    required this.message,
    required this.onRetry,
    required this.onLogout,
  });

  final AppLocalizations l10n;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: ColorsCustom.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: ColorsCustom.error,
              ),
            ),
            const SizedBox(height: 20),
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
            ButtonCustom.primary(text: l10n.retry, onPressed: onRetry),
            const SizedBox(height: 10),
            ButtonCustom.secondary(text: l10n.logout, onPressed: onLogout),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Dialog (shared) ──────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.description,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String description;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorsCustom.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogIcon(icon: icon, color: iconColor, bg: iconBg),
            const SizedBox(height: 18),
            TextCustom(
              text: title,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextCustom(
              text: description,
              fontSize: 13,
              color: ColorsCustom.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            ButtonCustom.primary(text: confirmText, onPressed: onConfirm),
            const SizedBox(height: 10),
            ButtonCustom.secondary(
              text: cancelText,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon({
    required this.icon,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

// ─── Language Dialog ──────────────────────────────────────────────────────────

class _LanguageDialog extends StatelessWidget {
  const _LanguageDialog({
    required this.l10n,
    required this.isArabic,
    required this.onSelectArabic,
    required this.onSelectEnglish,
    required this.onCancel,
  });

  final AppLocalizations l10n;
  final bool isArabic;
  final VoidCallback onSelectArabic;
  final VoidCallback onSelectEnglish;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorsCustom.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DialogIcon(
              icon: Icons.language_rounded,
              color: ColorsCustom.primary,
              bg: ColorsCustom.primarySoft,
            ),
            const SizedBox(height: 18),
            TextCustom(
              text: l10n.selectLanguage,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.textPrimary,
            ),
            const SizedBox(height: 18),
            _LanguageOption(
              title: 'العربية',
              subtitle: 'Arabic',
              isSelected: isArabic,
              onTap: onSelectArabic,
            ),
            const SizedBox(height: 10),
            _LanguageOption(
              title: 'English',
              subtitle: 'الإنجليزية',
              isSelected: !isArabic,
              onTap: onSelectEnglish,
            ),
            const SizedBox(height: 20),
            ButtonCustom.secondary(text: l10n.cancel, onPressed: onCancel),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsCustom.primarySoft
              : ColorsCustom.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? ColorsCustom.primary : ColorsCustom.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorsCustom.primary.withAlpha(24)
                    : ColorsCustom.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.language_rounded,
                size: 18,
                color: isSelected
                    ? ColorsCustom.primary
                    : ColorsCustom.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    text: title,
                    fontSize: 14,
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
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Delete Account Dialog ────────────────────────────────────────────────────

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({required this.onDeleted});

  final VoidCallback onDeleted;

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

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(
        () => _error = AppLocalizations.of(
          context,
        )!.deleteAccountPasswordRequired,
      );
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
              const _DialogIcon(
                icon: Icons.delete_forever_rounded,
                color: ColorsCustom.error,
                bg: ColorsCustom.errorBg,
              ),
              const SizedBox(height: 18),
              TextCustom(
                text: l10n.deleteAccount,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorsCustom.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextCustom(
                text: l10n.deleteAccountDescription,
                fontSize: 13,
                color: ColorsCustom.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              _PasswordField(
                controller: _passwordController,
                hint: l10n.deleteAccountPasswordHint,
                obscure: _obscurePassword,
                onToggleObscure: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 10),
              _ReasonField(
                controller: _reasonController,
                hint: l10n.deleteAccountReasonHint,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _error!),
              ],
              const SizedBox(height: 18),
              if (_isLoading)
                const SizedBox(
                  height: 46,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: ColorsCustom.error,
                      ),
                    ),
                  ),
                )
              else ...[
                ButtonCustom.primary(
                  text: l10n.deleteAccountConfirm,
                  onPressed: _submit,
                ),
                const SizedBox(height: 10),
                ButtonCustom.secondary(
                  text: l10n.cancel,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form Helpers ─────────────────────────────────────────────────────────────

InputDecoration _inputDecoration({
  required String hint,
  Widget? prefix,
  Widget? suffix,
  Color focusBorderColor = ColorsCustom.error,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: ColorsCustom.textHint, fontSize: 14),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: ColorsCustom.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
      borderSide: BorderSide(color: focusBorderColor, width: 1.5),
    ),
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggleObscure,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textDirection: TextDirection.ltr,
      decoration: _inputDecoration(
        hint: hint,
        prefix: const Icon(
          Icons.lock_outline_rounded,
          color: ColorsCustom.textSecondary,
          size: 20,
        ),
        suffix: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: ColorsCustom.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      decoration: _inputDecoration(hint: hint),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorsCustom.errorBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextCustom(
        text: message,
        fontSize: 13,
        color: ColorsCustom.error,
        textAlign: TextAlign.center,
      ),
    );
  }
}
