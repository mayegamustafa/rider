import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razinshop_rider/config/app_constants.dart';
import 'package:razinshop_rider/utils/api_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  return AuthService(ref);
}

abstract class AuthRepo {
  Future<Response> login({required String phone, required String password});
  Future<Response> sendOTP({required String phone, required bool isForgetPass});
  Future<Response> verifyOTP({required String phone, required String otp});
  Future<Response> registration({required Map<String, dynamic> data});
  Future<Response> checkUserStatus({required String phone});
  Future<Response> createPassword({required Map<String, dynamic> data});
  Future<Response> userDetails();
  Future<Response> changePassword({required Map<String, dynamic> data});
  Future<Response> checkPhoneAndEmail(
      {required String email, required String phone});
  Future<Response> logOut();
  Future<Response> updateProfile({required Map<String, dynamic> data});
}

class AuthService implements AuthRepo {
  final Ref ref;
  AuthService(this.ref);

  @override
  Future<Response> login({required String phone, required String password}) {
    return ref.read(apiClientProvider).post(AppConstants.loginUrl,
        data: {'phone': phone, 'password': password});
  }

  @override
  Future<Response> sendOTP({
    required String phone,
    required bool isForgetPass,
    String? email,
    bool? sendToEmail = false,
  }) async {
    print("\n--------- SENDING OTP REQUEST ---------");
    print("URL: ${AppConstants.sendOTPUrl}");
    print("Phone: $phone");
    print("Is Forgot Password: $isForgetPass");
    print("Email: $email");
    print("Send to Email: $sendToEmail");
    
    try {
      final response = await ref.read(apiClientProvider).post(
        AppConstants.sendOTPUrl, 
        data: {
          'phone': phone,
          'forgot_password': isForgetPass,
          'send_to_email': true, // Always try to send to email for forgot password
          if (email != null) 'email': email,
        },
      );
      
      print("\n--------- OTP API RESPONSE ---------");
      print("Status: ${response.statusCode}");
      print("Response: ${response.data}");
      
      return response;
    } catch (e) {
      print("\n--------- OTP API ERROR ---------");
      print("Error sending OTP: $e");
      rethrow;
    }
  }

  @override
  Future<Response> verifyOTP({required String phone, required String otp}) {
    return ref.read(apiClientProvider).post(AppConstants.verifyOTPUrl, data: {
      'phone': phone,
      'otp': otp,
    });
  }

  @override
  Future<Response> registration({required Map<String, dynamic> data}) async {
    print("\n--------- REGISTRATION API CALL ---------");
    print("URL: ${AppConstants.registrationUrl}");
    print("Request Data: $data");
    
    try {
      final formData = FormData.fromMap(data);
      print("FormData fields: ${formData.fields}");
      if (data['profile_photo'] != null) {
        print("Profile photo included in request");
      }
      
      final response = await ref
          .read(apiClientProvider)
          .post(AppConstants.registrationUrl, data: formData);
          
      print("\n--------- API RESPONSE ---------");
      print("Status: ${response.statusCode}");
      print("Response: ${response.data}");
      
      return response;
    } catch (e) {
      print("\n--------- API ERROR ---------");
      print("Error occurred while making registration request: $e");
      rethrow;
    }
  }

  @override
  Future<Response> checkUserStatus({required String phone}) {
    return ref
        .read(apiClientProvider)
        .get(AppConstants.checkUserStatusUrl, query: {'phone': phone});
  }

  @override
  Future<Response> logOut() {
    return ref.read(apiClientProvider).get(AppConstants.logoutUrl);
  }

  @override
  Future<Response> createPassword({required Map<String, dynamic> data}) {
    return ref
        .read(apiClientProvider)
        .post(AppConstants.createPasswordUrl, data: data);
  }

  @override
  Future<Response> userDetails() {
    return ref.read(apiClientProvider).get(AppConstants.userDetails);
  }

  @override
  Future<Response> changePassword({required Map<String, dynamic> data}) {
    return ref
        .read(apiClientProvider)
        .post(AppConstants.changePassword, data: data);
  }

  @override
  Future<Response> checkPhoneAndEmail(
      {required String email, required String phone}) async {
    final response = await ref.read(apiClientProvider).post(
        AppConstants.checkPhoneAndEmail,
        data: {'email': email, 'phone': phone});
    return response;
  }

  @override
  Future<Response> updateProfile({required Map<String, dynamic> data}) async {
    return ref
        .read(apiClientProvider)
        .post(AppConstants.profileUpdate, data: FormData.fromMap(data));
  }
}
