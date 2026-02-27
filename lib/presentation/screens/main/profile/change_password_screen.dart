import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/form_field_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        PasswordChangeRequested(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
    }
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
      appBar: AppBar(
        backgroundColor: ColorsCustom.surface,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsCustom.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: ColorsCustom.primary,
              ),
            ),
          ),
        ),
        title: TextCustom(
          text: l10n.changePassword,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is PasswordChangeSuccess) {
            _showSnackBar(l10n.passwordChangedSuccessfully);
            Navigator.pop(context);
          } else if (state is ProfileError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is PasswordChanging;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: ColorsCustom.primarySoft,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorsCustom.primary.withAlpha(51),
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 48,
                      color: ColorsCustom.primary.withAlpha(153),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextCustom(
                    text: l10n.useStrongPassword,
                    fontSize: 14,
                    color: ColorsCustom.textSecondary,
                  ),
                  const SizedBox(height: 28),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: ColorsCustom.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorsCustom.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormFieldCustom(
                          controller: _oldPasswordController,
                          label: l10n.currentPassword,
                          hintText: l10n.enterCurrentPassword,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.currentPasswordRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        FormFieldCustom(
                          controller: _newPasswordController,
                          label: l10n.newPassword,
                          hintText: l10n.enterNewPassword,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.newPasswordRequired;
                            }
                            if (value.length < 8) {
                              return l10n.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        FormFieldCustom(
                          controller: _confirmPasswordController,
                          label: l10n.confirmPassword,
                          hintText: l10n.reEnterNewPassword,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.confirmPasswordRequired;
                            }
                            if (value != _newPasswordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  ButtonCustom.primary(
                    text: l10n.changePassword,
                    onPressed: isLoading ? null : _changePassword,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorsCustom.textOnPrimary,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_rounded,
                            color: ColorsCustom.textOnPrimary,
                            size: 20,
                          ),
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
