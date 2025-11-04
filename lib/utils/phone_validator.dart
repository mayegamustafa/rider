import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter/material.dart';

class PhoneValidator {
  static String? validateUgandanPhone(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any whitespace, dashes or plus signs
    value = value.replaceAll(RegExp(r'\s+|-|\+'), '');

    // Check if the number starts with 0 or 256
    bool startsWithZero = value.startsWith('0');
    bool startsWithCountryCode = value.startsWith('256');

    // Convert number starting with 0 to include country code
    if (startsWithZero && value.length > 1) {
      value = '256${value.substring(1)}';
    }

    // Validate the length after normalization
    if (startsWithCountryCode && value.length != 12) {
      return 'Phone number must be 12 digits with country code';
    } else if (!startsWithCountryCode && !startsWithZero) {
      return 'Phone number must start with 0 or 256';
    }

    // Check if it's a valid Ugandan number format
    // Allowing common Ugandan prefixes (070, 071, 072, 074, 075, 077, 078, 079)
    RegExp ugandaPhoneRegex = RegExp(r'^256(70|71|72|74|75|77|78|79)[0-9]{7}$');
    if (!ugandaPhoneRegex.hasMatch(value)) {
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