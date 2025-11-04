import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';

class PhoneValidator {
  // Cache the regex pattern to avoid recompilation
  static final RegExp _phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  static final RegExp _cleanupRegex = RegExp(r'\s+|-');

  static String? validateUgandanPhone(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any whitespace and dashes but keep the + sign
    value = value.replaceAll(_cleanupRegex, '');

    // Quick length check before further processing
    if (value.length < 8 || value.length > 15) {
      return 'Invalid phone number length';
    }

    // If number starts with 0, assume it's a local number
    if (value.startsWith('0')) {
      value = value.substring(1);
    }

    // Make sure it matches international format
    if (!_phoneRegex.hasMatch(value)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  static String normalizeUgandanPhone(String phoneNumber) {
    // Remove any whitespace and dashes but keep the + sign
    phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');

    // If it doesn't start with +, add it
    if (!phoneNumber.startsWith('+')) {
      // If it starts with 0, remove it first
      if (phoneNumber.startsWith('0')) {
        phoneNumber = phoneNumber.substring(1);
      }
      phoneNumber = '+$phoneNumber';
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