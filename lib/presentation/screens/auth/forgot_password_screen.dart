import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/screens/auth/reset_password_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumber? _phoneNumber;

  void _sendResetCode() {
    if (_phoneNumber == null || _phoneNumber!.number.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ShowMessage.error(context, l10n.phoneRequired);
      return;
    }

    final phone = _phoneNumber!.completeNumber;

    context.read<AuthBloc>().add(AuthResetPasswordRequested(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black87,
          ),
        ),
        title: TextCustom(
          text: l10n.forgotPassword,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            LoadingModal.show(context, message: l10n.sendingVerificationCode);
          } else if (state is AuthResetCodeSent) {
            LoadingModal.dismiss(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ResetPasswordScreen(phone: state.phone),
              ),
            );
          } else if (state is AuthError) {
            LoadingModal.dismiss(context);
            ShowMessage.error(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 50),
                  _buildPhoneField(l10n),
                  const SizedBox(height: 40),
                  _buildSendCodeButton(l10n),
                  const SizedBox(height: 24),
                  _buildBackToLogin(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 50,
            color: Color(0xFFD32F2F),
          ),
        ),
        const SizedBox(height: 20),
        TextCustom(
          text: l10n.forgotPassword,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextCustom(
          text: l10n.enterPhoneToReset,
          fontSize: 16,
          color: ColorsCustom.accent,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: TextCustom(
            text: l10n.phoneNumber,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: IntlPhoneField(
              initialCountryCode: 'SY',
              languageCode: Localizations.localeOf(context).languageCode,
              disableLengthCheck: true,
              autovalidateMode: AutovalidateMode.disabled,
              showCountryFlag: true,
              showDropdownIcon: false,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              flagsButtonPadding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: InputDecoration(
                hintText: '9XX XXX XXX',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                filled: false,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: ColorsCustom.primary, width: 2),
                ),
              ),
              onChanged: (phone) => setState(() => _phoneNumber = phone),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendCodeButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _sendResetCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: TextCustom(
          text: l10n.sendCode,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBackToLogin(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          text: l10n.rememberPassword,
          fontSize: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: TextCustom(
            text: l10n.signIn,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.accent,
          ),
        ),
      ],
    );
  }
}
