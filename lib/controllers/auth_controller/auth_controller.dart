import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:razinshop_rider/config/app_constants.dart';
import 'package:razinshop_rider/services/auth_service.dart';
import 'package:razinshop_rider/utils/phone_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@riverpod
class Login extends _$Login {
  @override
  bool build() {
    return false;
  }

  Future<bool> login({required String phone, required String password}) async {
    state = true;
    try {
      print("\n--------- LOGIN ATTEMPT ---------");
      print("Original Phone: $phone");
      print("Password Length: ${password.length}");
      
      // Normalize phone number and validate
      final normalizedPhone = PhoneValidator.normalizeUgandanPhone(phone);
      print("Normalized Phone: $normalizedPhone");
      
      if (!RegExp(r'^\+256\d{9}$').hasMatch(normalizedPhone)) {
        print("\n--------- VALIDATION ERROR ---------");
        print("Invalid phone number format");
        throw Exception("Invalid phone number format. Please enter a valid Ugandan phone number.");
      }
      
      final response = await ref
          .read(authServiceProvider)
          .login(phone: normalizedPhone, password: password);
      
      print("\n--------- SERVER RESPONSE ---------");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        print("\n--------- DATA PROCESSING ---------");
        print("Raw Data: $data");
        
        // Check for error messages in response
        if (data['error'] != null || 
            (data['message']?.toString().toLowerCase().contains('invalid') ?? false)) {
          print("\n--------- LOGIN ERROR ---------");
          print("API Error: ${data['message'] ?? data['error']}");
          throw Exception(data['message'] ?? data['error'] ?? "Invalid credentials");
        }
        
        String? token = data['data']?['token'] ?? data['token'];
        print("Extracted Token: $token");
        
        if (token != null) {
          Box authBox = Hive.box(AppConstants.authBox);
          authBox.put(AppConstants.authToken, token);
          
          // Store user data
          final userData = data['data'] ?? data;
          print("User Data to Store: $userData");
          authBox.put(AppConstants.userData, userData);
          
          print("\n--------- LOGIN SUCCESS ---------");
          print("Token and User Data stored successfully");
          state = false;
          return true;
        }
      }
      
      // If response indicates an error
      if (response.data?['message'] != null) {
        throw Exception(response.data!['message']);
      }
      
      print("\n--------- LOGIN FAILED ---------");
      print("Reason: Invalid response structure or missing token");
      throw Exception("Login failed. Please check your credentials and try again.");
      
    } catch (e) {
      print("\n--------- LOGIN ERROR ---------");
      print("Error Details: $e");
      state = false;
      rethrow; // Re-throw the error to handle it in the UI
    }
  }
}

@riverpod
class SendOTP extends _$SendOTP {
  @override
  bool build() {
    return false;
  }

  Future<Map<String, dynamic>> sendOTP({
    required String phone,
    required bool isForgetPass,
    String? email,
    bool? sendToEmail,
  }) async {
    state = true;
    try {
      final response = await ref
          .read(authServiceProvider)
          .sendOTP(
            phone: phone,
            isForgetPass: isForgetPass,
            email: email,
            sendToEmail: sendToEmail,
          );
      
      print("OTP Response: ${response.data}"); // Debug log
      
      if (response.statusCode == 200) {
        state = false;
        final otp = response.data['data']?['otp']?.toString() ?? 
                   response.data['otp']?.toString();
                   
        if (otp != null) {
          return {
            'success': true,
            'otp': otp,
            'message': sendToEmail == true 
                ? 'OTP sent to your email' 
                : 'OTP sent to your phone'
          };
        }
      }
      state = false;
      return {
        'success': false,
        'message': 'Failed to send OTP'
      };
    } catch (e) {
      print("Send OTP error: $e");
      state = false;
      return {
        'success': false,
        'message': 'Error sending OTP: ${e.toString()}'
      };
    }
  }
}

@riverpod
class VerifyOTP extends _$VerifyOTP {
  @override
  bool build() {
    return false;
  }

  Future<String?> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    state = true;
    final response = await ref
        .read(authServiceProvider)
        .verifyOTP(phone: phone, otp: otp);
    if (response.statusCode == 200) {
      state = false;
      String? token = response.data['data']['token'];
      return token;
    } else {
      state = false;
      return null;
    }
  }
}

@riverpod
class Registration extends _$Registration {
  @override
  bool build() {
    return false;
  }

  Future<bool> registration({required Map<String, dynamic> data}) async {
    state = true;
    try {
      print("\n--------- REGISTRATION ATTEMPT ---------");
      print("Registration Data: ${data.toString()}");
      
      // Validate required fields
      final requiredFields = [
        'first_name',
        'last_name',
        'phone',
        'email',
        'gender',
        'date_of_birth',
        'driving_licence',
        'vehicle_type',
        'profile_photo'
      ];

      for (var field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null || data[field].toString().isEmpty) {
          print('\n--------- VALIDATION ERROR ---------');
          print('Missing or empty required field: $field');
          state = false;
          return false;
        }
      }

      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(data['email'])) {
        print('\n--------- VALIDATION ERROR ---------');
        print('Invalid email format: ${data['email']}');
        state = false;
        return false;
      }
      
      final response = await ref
          .read(authServiceProvider)
          .registration(data: data);
      
      print("\n--------- SERVER RESPONSE ---------");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("Response Headers: ${response.headers}");
      
      if (response.statusCode == 200) {
        print("\n--------- DATA PROCESSING ---------");
        if (response.data['data']?['token'] != null) {
          Box authBox = Hive.box(AppConstants.authBox);
          print("Storing token: ${response.data['data']['token']}");
          authBox.put(AppConstants.authToken, response.data['data']['token']);
          
          // Store user data if available
          if (response.data['data']?['user'] != null) {
            print("Storing user data: ${response.data['data']['user']}");
            authBox.put(AppConstants.userData, response.data['data']['user']);
          }
        } else {
          print("No token found in response");
        }
        print("\n--------- REGISTRATION SUCCESS ---------");
        state = false;
        return true;
      }
      print("\n--------- REGISTRATION FAILED ---------");
      print("Failed with status code: ${response.statusCode}");
      print("Error message: ${response.data['message'] ?? 'No error message provided'}");
      state = false;
      return false;
    } catch (e) {
      print("\n--------- REGISTRATION ERROR ---------");
      print("Error type: ${e.runtimeType}");
      print("Error details: $e");
      state = false;
      return false;
    }
  }
}

@riverpod
class CheckUserStatus extends _$CheckUserStatus {
  @override
  void build(String arg) async {
    Box authBox = Hive.box(AppConstants.authBox);
    final response = await ref
        .read(authServiceProvider)
        .checkUserStatus(phone: arg);
    if (response.data['data']['user_status'] == true) {
      authBox.delete(AppConstants.isInReview);
    }
  }
}

@riverpod
class LogOut extends _$LogOut {
  @override
  bool build() {
    return false;
  }

  Future<bool> logOut() async {
    final response = await ref.read(authServiceProvider).logOut();
    Box authBox = Hive.box(AppConstants.authBox);
    state = true;
    if (response.statusCode == 200) {
      authBox.delete(AppConstants.authToken);
      authBox.delete(AppConstants.userData);
      state = false;
      return true;
    } else {
      state = false;
      return false;
    }
  }
}

@riverpod
class CreatePassword extends _$CreatePassword {
  @override
  bool build() {
    return false;
  }

  Future<bool> createPassword({required Map<String, dynamic> data}) async {
    state = true;
    final response = await ref
        .read(authServiceProvider)
        .createPassword(data: data);
    if (response.statusCode == 200) {
      state = false;
      return true;
    } else {
      state = false;
      return false;
    }
  }
}

@Riverpod(keepAlive: true)
class UserDetails extends _$UserDetails {
  @override
  FutureOr<void> build() async {
    final response = await ref.read(authServiceProvider).userDetails();
    if (response.statusCode == 200) {
      final data = response.data['data'];
      Box authBox = Hive.box(AppConstants.authBox);
      authBox.put(AppConstants.userData, data);
    }
  }
}

@riverpod
class ChangePassword extends _$ChangePassword {
  @override
  bool build() {
    return false;
  }

  Future<bool> changePassword({required Map<String, dynamic> data}) async {
    state = true;
    final response = await ref
        .read(authServiceProvider)
        .changePassword(data: data);
    if (response.statusCode == 200) {
      state = false;
      return true;
    } else {
      state = false;
      return false;
    }
  }
}

@riverpod
class CheckPhoneAndEmailProvider extends _$CheckPhoneAndEmailProvider {
  @override
  bool build() {
    return false;
  }

  Future<Map<String, dynamic>> checkPhoneAndEmail({
    required String email,
    required String phone,
  }) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .checkPhoneAndEmail(email: email, phone: phone);
      state = false;
      final status = response.statusCode == 200;
      return {'status': status, 'message': response.data['data']['message']};
    } catch (e) {
      state = false;
      return {'status': false, 'message': e.toString()};
    }
  }
}

class ValidationNotifier extends StateNotifier<bool> {
  final Ref ref;

  ValidationNotifier(this.ref) : super(false);
  Future<Map<String, dynamic>> checkPhoneAndEmail({
    required String email,
    required String phone,
  }) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .checkPhoneAndEmail(email: email, phone: phone);
      state = false;
      final status = response.statusCode == 200;
      return {'status': status, 'message': response.data['message']};
    } catch (e) {
      state = false;
      return {'status': false, 'message': e.toString()};
    }
  }
}

final validationProvider = StateNotifierProvider<ValidationNotifier, bool>(
  (ref) => ValidationNotifier(ref),
);

@riverpod
class UpdateProfile extends _$UpdateProfile {
  @override
  bool build() {
    return false;
  }

  Future<bool> updateProfile({required Map<String, dynamic> data}) async {
    state = true;
    final response = await ref
        .read(authServiceProvider)
        .updateProfile(data: data);
    if (response.statusCode == 200) {
      state = false;
      return true;
    } else {
      state = false;
      return false;
    }
  }
}
