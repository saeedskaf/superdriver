import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/form_field_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/helpers/validate_form.dart';
import 'package:superdriver/presentation/screens/auth/reset_password_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  PhoneNumber? _phoneNumber;
  String? _phoneError;

  void _sendResetCode() {
    final phoneValue = _phoneNumber?.number ?? '';
    final phoneValidation = FormValidators(context).phoneValidator(phoneValue);
    setState(() => _phoneError = phoneValidation);

    if (_phoneError != null) return;

    final phone = _phoneNumber!.completeNumber;
    context.read<AuthBloc>().add(AuthResetPasswordRequested(phone: phone));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.surface,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                _buildBackButton(),
                const SizedBox(height: 16),
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
    );
  }

  Widget _buildBackButton() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ColorsCustom.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: ColorsCustom.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: ColorsCustom.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              'assets/icons/forgot_password_illustration.png',
              width: 75,
              height: 75,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextCustom.heading(
          text: l10n.forgotPassword,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextCustom(
          text: l10n.enterPhoneToReset,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.secondaryDark,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneField(AppLocalizations l10n) {
    return PhoneFieldCustom(
      label: l10n.phoneNumber,
      errorText: _phoneError,
      onChanged: (phone) {
        setState(() {
          _phoneNumber = phone;
          if (_phoneError != null) {
            _phoneError = FormValidators(context).phoneValidator(phone.number);
          }
        });
      },
    );
  }

  Widget _buildSendCodeButton(AppLocalizations l10n) {
    return ButtonCustom.primary(text: l10n.sendCode, onPressed: _sendResetCode);
  }

  Widget _buildBackToLogin(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          text: l10n.rememberPassword,
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.textPrimary,
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: TextCustom(
            text: l10n.signIn,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.primary,
          ),
        ),
      ],
    );
  }
}
