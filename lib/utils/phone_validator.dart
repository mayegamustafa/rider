import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';

class PhoneValidator {
  // Cache the regex pattern to avoid recompilation
  static final RegExp _ugandaPhoneRegex = RegExp(r'^256(70|71|72|74|75|77|78|79)[0-9]{7}$');
  static final RegExp _cleanupRegex = RegExp(r'\s+|-|\+');

  static String? validateUgandanPhone(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any whitespace, dashes or plus signs
    value = value.replaceAll(_cleanupRegex, '');

    // Quick length check before further processing
    if (value.length < 10 || value.length > 12) {
      return 'Invalid phone number length';
    }

    // Check if the number starts with 0 or 256
    if (value.startsWith('0')) {
      value = '256${value.substring(1)}';
    }

    // Final validation with regex
    if (!_ugandaPhoneRegex.hasMatch(value)) {
      return 'Invalid Uganda phone number format';
    }

    return null;
  }

  static String normalizeUgandanPhone(String phoneNumber) {
    // Remove any whitespace, dashes or plus signs
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|-|\+'), '');

    // If number starts with 0, replace it with 256
    if (phoneNumber.startsWith('0') && phoneNumber.length > 1) {
      phoneNumber = '256${phoneNumber.substring(1)}';
    }

    return phoneNumber;
  }

  /// Formats the phone number for display (adds spaces for readability)
  static String formatPhoneNumber(String phoneNumber) {
    // First normalize the number
    phoneNumber = normalizeUgandanPhone(phoneNumber);
    
    // If it's a valid 12-digit number, format it as "256 7XX XXX XXX"
    if (phoneNumber.length == 12) {
      return '${phoneNumber.substring(0, 3)} ${phoneNumber.substring(3, 6)} ${phoneNumber.substring(6, 9)} ${phoneNumber.substring(9)}';
    }
    
    return phoneNumber;
  }
}