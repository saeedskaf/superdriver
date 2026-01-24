import 'package:flutter/material.dart';
import 'package:superdriver/l10n/app_localizations.dart';

class FormValidators {
  final BuildContext context;

  FormValidators(this.context);

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  // ==================== Authentication Validators ====================

  // Phone number validator (primary login method)
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.phoneRequired;
    }
    // Remove spaces and special characters for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.length < 8) {
      return l10n.phoneTooShort;
    }
    if (cleanPhone.length > 15) {
      return l10n.phoneTooLong;
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanPhone)) {
      return l10n.phoneOnlyNumbers;
    }
    return null;
  }

  // Password validator
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.passwordRequired;
    }
    if (value.length < 8) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  // Password match validator (for confirm password)
  String? passwordMatchValidator(String password, String? value) {
    if (value == null || value.isEmpty) {
      return l10n.confirmPasswordRequired;
    }
    if (value != password) {
      return l10n.passwordsNotMatch;
    }
    return null;
  }

  // First name validator
  String? firstNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.firstNameRequired;
    }
    if (value.trim().length < 2) {
      return l10n.firstNameTooShort;
    }
    if (value.length > 50) {
      return l10n.firstNameTooLong;
    }
    return null;
  }

  // Last name validator
  String? lastNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.lastNameRequired;
    }
    if (value.trim().length < 2) {
      return l10n.lastNameTooShort;
    }
    if (value.length > 50) {
      return l10n.lastNameTooLong;
    }
    return null;
  }

  // OTP validator (6 digits)
  String? otpValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.otpRequired;
    }
    if (value.length != 6) {
      return l10n.otpInvalid;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return l10n.otpOnlyNumbers;
    }
    return null;
  }

  // ==================== Order Validators ====================

  // Order description/request validator
  String? orderDescriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.orderDescriptionRequired;
    }
    if (value.trim().length < 10) {
      return l10n.orderDescriptionTooShort;
    }
    if (value.length > 500) {
      return l10n.orderDescriptionTooLong;
    }
    return null;
  }

  // Delivery address validator
  String? deliveryAddressValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.deliveryAddressRequired;
    }
    if (value.trim().length < 5) {
      return l10n.deliveryAddressTooShort;
    }
    if (value.length > 200) {
      return l10n.deliveryAddressTooLong;
    }
    return null;
  }

  // Optional delivery notes validator
  String? deliveryNotesValidator(String? value) {
    if (value != null && value.length > 500) {
      return l10n.notesTooLong;
    }
    return null;
  }

  // ==================== Chat & Support Validators ====================

  // Chat message validator
  String? chatMessageValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.chatMessageRequired;
    }
    if (value.trim().isEmpty) {
      return l10n.chatMessageRequired;
    }
    if (value.length > 1000) {
      return l10n.chatMessageTooLong;
    }
    return null;
  }

  // Support ticket title validator
  String? ticketTitleValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.ticketTitleRequired;
    }
    if (value.trim().length < 5) {
      return l10n.ticketTitleTooShort;
    }
    if (value.length > 100) {
      return l10n.ticketTitleTooLong;
    }
    return null;
  }

  // Support ticket description validator
  String? ticketDescriptionValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.ticketDescriptionRequired;
    }
    if (value.trim().length < 20) {
      return l10n.ticketDescriptionTooShort;
    }
    if (value.length > 1000) {
      return l10n.ticketDescriptionTooLong;
    }
    return null;
  }

  // ==================== General Validators ====================

  // Required field validator (generic)
  String? requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  // Optional notes validator (generic)
  String? notesValidator(String? value) {
    if (value != null && value.length > 500) {
      return l10n.notesTooLong;
    }
    return null;
  }

  // Email validator (optional - for future use if needed)
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return l10n.emailInvalid;
    }
    return null;
  }

  // ==================== Helper Methods ====================

  // Combine validators (chain multiple validators)
  String? Function(String?) combineValidators(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
