import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superdriver/domain/bloc/profile/profile_bloc.dart';
import 'package:superdriver/l10n/app_localizations.dart';
import 'package:superdriver/presentation/components/text_custom.dart';
import 'package:superdriver/presentation/components/btn_custom.dart';
import 'package:superdriver/presentation/components/form_field_custom.dart';
import 'package:superdriver/presentation/themes/colors_custom.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _phoneNumber = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    final state = context.read<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _populateFields(state);
    } else {
      context.read<ProfileBloc>().add(const ProfileLoadRequested());
    }
  }

  void _populateFields(ProfileLoaded state) {
    if (!_isInitialized) {
      _firstNameController.text = state.firstName;
      _lastNameController.text = state.lastName;
      _phoneNumber = state.phoneNumber;
      _isInitialized = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<ProfileBloc>().add(
        ProfileUpdateRequested(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
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
          text: l10n.editProfile,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsCustom.textPrimary,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && !_isInitialized) {
            _populateFields(state);
          }
          if (state is ProfileUpdateSuccess) {
            _showSnackBar(l10n.profileUpdatedSuccessfully);
            Navigator.pop(context);
          } else if (state is ProfileError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating;
          final isLoadingProfile = state is ProfileLoading;

          if (isLoadingProfile && !_isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ColorsCustom.primary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
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
                      Icons.person_rounded,
                      size: 48,
                      color: ColorsCustom.primary.withAlpha(153),
                    ),
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
                          controller: _firstNameController,
                          label: l10n.firstName,
                          hintText: l10n.enterFirstName,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.firstNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        FormFieldCustom(
                          controller: _lastNameController,
                          label: l10n.lastName,
                          hintText: l10n.enterLastName,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.lastNameRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone (read-only)
                        TextCustom(
                          text: l10n.phoneNumber,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorsCustom.textPrimary,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ColorsCustom.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: ColorsCustom.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: ColorsCustom.surface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 16,
                                  color: ColorsCustom.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatPhoneNumber(_phoneNumber),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: ColorsCustom.textSecondary,
                                    fontFamily: 'Cairo',
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: ColorsCustom.textHint,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TextCustom(
                                text: l10n.phoneNumberCannotBeChanged,
                                fontSize: 12,
                                color: ColorsCustom.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Save button
                  ButtonCustom.primary(
                    text: l10n.saveChanges,
                    onPressed: isLoading ? null : _saveProfile,
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
