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
  String? _phoneError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final phoneValue = _phoneNumber?.number ?? '';
    final phoneValidation = FormValidators(context).phoneValidator(phoneValue);
    setState(() => _phoneError = phoneValidation);

    if (!_formKey.currentState!.validate()) return;
    if (_phoneError != null) return;

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
      backgroundColor: ColorsCustom.surface,
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(l10n),
                  const SizedBox(height: 40),
                  _buildPhoneField(l10n),
                  const SizedBox(height: 20),
                  _buildPasswordField(l10n),
                  const SizedBox(height: 12),
                  _buildForgotPassword(l10n),
                  const SizedBox(height: 40),
                  _buildLoginButton(l10n),
                  const SizedBox(height: 24),
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
        Image.asset(
          'assets/icons/login_illustration.png',
          width: 140,
          height: 170,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 24),
        TextCustom.heading(
          text: l10n.welcomeMessage,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextCustom(
          text: l10n.signInToContinue,
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

  Widget _buildPasswordField(AppLocalizations l10n) {
    return FormFieldCustom(
      controller: _passwordController,
      label: l10n.password,
      isPassword: true,
      validator: FormValidators(context).passwordValidator,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _login(),
    );
  }

  Widget _buildForgotPassword(AppLocalizations l10n) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
          );
        },
        child: TextCustom(
          text: l10n.forgotPassword,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ColorsCustom.primary,
        ),
      ),
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n) {
    return ButtonCustom.primary(text: l10n.login, onPressed: _login);
  }

  Widget _buildRegisterLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          text: l10n.dontHaveAccount,
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.textPrimary,
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: TextCustom(
            text: l10n.register,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ColorsCustom.primary,
          ),
        ),
      ],
    );
  }
}
