import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/helpers/validate_form.dart';
import 'package:superdriver/presentation/screens/main/main_screen.dart';
import 'package:superdriver/presentation/screens/auth/forgot_password_screen.dart';
import 'package:superdriver/presentation/screens/auth/register_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  PhoneNumber? _phoneNumber;
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_phoneNumber == null || _phoneNumber!.number.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ShowMessage.error(context, l10n.phoneRequired);
      return;
    }

    final phone = _phoneNumber!.completeNumber;
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
      AuthLoginRequested(phone: phone, password: password),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            LoadingModal.show(context, message: l10n.loading);
          } else if (state is AuthAuthenticated) {
            LoadingModal.dismiss(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainScreen()),
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
                  const SizedBox(height: 20),
                  _buildPasswordField(l10n),
                  const SizedBox(height: 12),
                  _buildForgotPassword(l10n),
                  const SizedBox(height: 40),
                  _buildLoginButton(l10n),
                  const SizedBox(height: 30),
                  _buildRegisterLink(l10n),
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
        // Super Driver Character
        Image.asset(
          'assets/icons/motorbike.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 30),

        // Welcome Title (Using localized text)
        TextCustom(
          text: l10n.welcomeMessage,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Subtitle
        TextCustom(
          text: l10n.signInToContinue,
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

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, right: 4),
          child: TextCustom(
            text: l10n.password,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            validator: FormValidators(context).passwordValidator,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _login(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: l10n.password,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
              filled: false,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorsCustom.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: ColorsCustom.error, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: TextCustom(
          text: l10n.forgotPassword,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD32F2F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: TextCustom(
          text: l10n.login,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          text: l10n.dontHaveAccount,
          fontSize: 16,
          color: Colors.black87,
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: TextCustom(
            text: l10n.register,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: ColorsCustom.accent,
          ),
        ),
      ],
    );
  }
}
