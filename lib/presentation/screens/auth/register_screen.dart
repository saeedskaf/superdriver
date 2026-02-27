import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:superdriver/domain/bloc/auth/auth_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/form_field_custom.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/helpers/modal_loading.dart';
import 'package:superdriver/presentation/helpers/show_message.dart';
import 'package:superdriver/presentation/helpers/validate_form.dart';
import 'package:superdriver/presentation/screens/auth/otp_screen.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  PhoneNumber? _phoneNumber;
  String? _phoneError;

  static const String _termsUrl = 'https://yourdomain.com/terms';
  static const String _privacyUrl = 'https://yourdomain.com/privacy';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    final phoneValue = _phoneNumber?.number ?? '';
    final phoneValidation = FormValidators(context).phoneValidator(phoneValue);
    setState(() => _phoneError = phoneValidation);

    if (!_formKey.currentState!.validate()) return;
    if (_phoneError != null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneNumber!.completeNumber;
    final password = _passwordController.text;

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        password: password,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
          } else if (state is AuthOtpSent) {
            LoadingModal.dismiss(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpScreen(
                  phone: state.phone,
                  verificationId: state.verificationId,
                  userData: state.userData,
                ),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildBackButton(),
                  const SizedBox(height: 16),
                  _buildHeader(l10n),
                  const SizedBox(height: 40),
                  _buildFirstNameField(l10n),
                  const SizedBox(height: 20),
                  _buildLastNameField(l10n),
                  const SizedBox(height: 20),
                  _buildPhoneField(l10n),
                  const SizedBox(height: 20),
                  _buildPasswordField(l10n),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(l10n),
                  const SizedBox(height: 40),
                  _buildRegisterButton(l10n),
                  const SizedBox(height: 24),
                  _buildLoginLink(l10n),
                  const SizedBox(height: 16),
                  _buildTerms(l10n),
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
        TextCustom.heading(
          text: l10n.createAccount,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextCustom(
          text: l10n.enterDetailsToStart,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: ColorsCustom.secondaryDark,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFirstNameField(AppLocalizations l10n) {
    return FormFieldCustom(
      controller: _firstNameController,
      label: l10n.firstName,
      validator: FormValidators(context).firstNameValidator,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(
        Icons.person_outline,
        color: ColorsCustom.textHint,
        size: 22,
      ),
    );
  }

  Widget _buildLastNameField(AppLocalizations l10n) {
    return FormFieldCustom(
      controller: _lastNameController,
      label: l10n.lastName,
      validator: FormValidators(context).lastNameValidator,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(
        Icons.person_outline,
        color: ColorsCustom.textHint,
        size: 22,
      ),
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
      onSubmitted: (_) => _register(),
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n) {
    return ButtonCustom.primary(text: l10n.register, onPressed: _register);
  }

  Widget _buildLoginLink(AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          text: l10n.alreadyHaveAccount,
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

  Widget _buildTerms(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.tajawal(
            fontSize: 12,
            color: ColorsCustom.textSecondary,
            height: 1.6,
            letterSpacing: 0,
          ),
          children: [
            TextSpan(text: '${l10n.byCreatingAccount}\n'),
            TextSpan(
              text: l10n.termsOfService,
              style: GoogleFonts.tajawal(
                color: ColorsCustom.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(_termsUrl),
            ),
            TextSpan(text: ' ${l10n.and} '),
            TextSpan(
              text: l10n.privacyPolicy,
              style: GoogleFonts.tajawal(
                color: ColorsCustom.primary,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _launchUrl(_privacyUrl),
            ),
          ],
        ),
      ),
    );
  }
}
