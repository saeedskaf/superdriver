import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/form_field_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/helpers/validate_form.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;

  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _resetPassword() {
    if (!_formKey.currentState!.validate()) return;

    final otp = _otpController.text;
    if (otp.length != 6) {
      final l10n = AppLocalizations.of(context)!;
      ShowMessage.error(context, l10n.invalidOtp);
      return;
    }

    final newPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    context.read<AuthBloc>().add(
      AuthPasswordResetConfirmed(
        phone: widget.phone,
        otpCode: otp,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );
  }

  void _resendOtp() {
    if (!_canResend) return;

    context.read<AuthBloc>().add(
      AuthResendOtpRequested(phone: widget.phone, otpType: 'forgot_password'),
    );

    _startTimer();
    final l10n = AppLocalizations.of(context)!;
    ShowMessage.success(context, l10n.otpResent);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorsCustom.surface,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            LoadingModal.show(context, message: l10n.resettingPassword);
          } else if (state is AuthPasswordResetSuccess) {
            LoadingModal.dismiss(context);
            ShowMessage.success(context, l10n.passwordResetSuccess);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          } else if (state is AuthError) {
            LoadingModal.dismiss(context);
            ShowMessage.error(context, state.message);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 16),
                  _buildHeader(l10n),
                  const SizedBox(height: 40),
                  _buildOtpInput(),
                  const SizedBox(height: 20),
                  _buildPasswordField(l10n),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(l10n),
                  const SizedBox(height: 40),
                  _buildResetButton(l10n),
                  const SizedBox(height: 24),
                  _buildResendSection(l10n),
                  const SizedBox(height: 24),
                ],
              ),
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
              'assets/icons/reset_password_illustration.png',
              width: 75,
              height: 75,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextCustom.heading(
          text: l10n.resetPassword,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextCustom(
          text: l10n.enterOtpSentTo,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.secondaryDark,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextCustom(
              text: widget.phone,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: ColorsCustom.secondaryDark,
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextCustom(
                      text: l10n.changePhoneNumber,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: ColorsCustom.secondaryDark,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -4),
                      child: Container(
                        height: 1,
                        color: ColorsCustom.secondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    final defaultTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ColorsCustom.textPrimary,
      ),
      decoration: BoxDecoration(
        color: ColorsCustom.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsCustom.border),
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        controller: _otpController,
        focusNode: _focusNode,
        length: 6,
        defaultPinTheme: defaultTheme,
        focusedPinTheme: defaultTheme.copyWith(
          decoration: BoxDecoration(
            color: ColorsCustom.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.primary, width: 1.5),
          ),
        ),
        submittedPinTheme: defaultTheme.copyWith(
          decoration: BoxDecoration(
            color: ColorsCustom.primarySoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.primary),
          ),
        ),
        errorPinTheme: defaultTheme.copyWith(
          decoration: BoxDecoration(
            color: ColorsCustom.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorsCustom.error),
          ),
        ),
        showCursor: true,
        cursor: Container(width: 2, height: 24, color: ColorsCustom.primary),
      ),
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return FormFieldCustom(
      controller: _passwordController,
      label: l10n.newPassword,
      isPassword: true,
      validator: FormValidators(context).passwordValidator,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return FormFieldCustom(
      controller: _confirmPasswordController,
      label: l10n.confirmPassword,
      isPassword: true,
      validator: (value) => FormValidators(
        context,
      ).passwordMatchValidator(_passwordController.text, value),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _resetPassword(),
    );
  }

  Widget _buildResetButton(AppLocalizations l10n) {
    return ButtonCustom.primary(
      text: l10n.resetPassword,
      onPressed: _resetPassword,
    );
  }

  Widget _buildResendSection(AppLocalizations l10n) {
    return Column(
      children: [
        TextCustom(
          text: l10n.didntReceiveCode,
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.textSecondary,
        ),
        const SizedBox(height: 8),
        if (_canResend)
          GestureDetector(
            onTap: _resendOtp,
            child: TextCustom(
              text: l10n.resend,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorsCustom.secondaryDark,
            ),
          )
        else
          TextCustom(
            text: '${l10n.resendIn} $_remainingSeconds ${l10n.seconds}',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.textSecondary,
          ),
      ],
    );
  }
}
