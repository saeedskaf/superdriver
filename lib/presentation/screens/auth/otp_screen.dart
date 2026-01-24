import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/screens/auth/login_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final Map<String, dynamic>? userData;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.userData,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
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

  void _verifyOtp() {
    final otp = _otpController.text;

    if (otp.length != 6) {
      final l10n = AppLocalizations.of(context)!;
      ShowMessage.error(context, l10n.invalidOtp);
      return;
    }

    context.read<AuthBloc>().add(
      AuthOtpVerificationRequested(
        phone: widget.phone,
        otp: otp,
        userData: widget.userData,
      ),
    );
  }

  void _resendOtp() {
    if (!_canResend) return;

    context.read<AuthBloc>().add(
      AuthResendOtpRequested(phone: widget.phone, otpType: 'signup'),
    );

    _startTimer();
    final l10n = AppLocalizations.of(context)!;
    ShowMessage.success(context, l10n.otpResent);
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
          text: l10n.verifyPhone,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            LoadingModal.show(context, message: l10n.verifyingCode);
          } else if (state is AuthRegistrationSuccess) {
            LoadingModal.dismiss(context);
            ShowMessage.success(context, 'تم التحقق بنجاح! يرجى تسجيل الدخول');
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(l10n),
                const SizedBox(height: 50),
                _buildOtpInput(),
                const SizedBox(height: 40),
                _buildVerifyButton(l10n),
                const SizedBox(height: 24),
                _buildResendSection(l10n),
              ],
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
            Icons.sms_outlined,
            size: 50,
            color: Color(0xFFD32F2F),
          ),
        ),
        const SizedBox(height: 20),
        TextCustom(
          text: l10n.verifyPhone,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextCustom(
          text: l10n.enterOtpSent,
          fontSize: 16,
          color: ColorsCustom.accent,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextCustom(
          text: widget.phone,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        controller: _otpController,
        focusNode: _focusNode,
        length: 6,
        defaultPinTheme: PinTheme(
          width: 50,
          height: 56,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        focusedPinTheme: PinTheme(
          width: 50,
          height: 56,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsCustom.primary, width: 2),
          ),
        ),
        submittedPinTheme: PinTheme(
          width: 50,
          height: 56,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD32F2F).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorsCustom.primary),
          ),
        ),
        showCursor: true,
        onCompleted: (_) => _verifyOtp(),
      ),
    );
  }

  Widget _buildVerifyButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _verifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: TextCustom(
          text: l10n.verify,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildResendSection(AppLocalizations l10n) {
    return Column(
      children: [
        TextCustom(
          text: l10n.didntReceiveCode,
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(height: 8),
        if (_canResend)
          TextButton(
            onPressed: _resendOtp,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: TextCustom(
              text: l10n.resend,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ColorsCustom.accent,
            ),
          )
        else
          TextCustom(
            text: '${l10n.resendIn} $_remainingSeconds ${l10n.seconds}',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
      ],
    );
  }
}
