import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:razinshop_rider/components/my_custom_button.dart';
import 'package:razinshop_rider/config/app_color.dart';
import 'package:razinshop_rider/config/theme.dart';
import 'package:razinshop_rider/controllers/auth_controller/auth_controller.dart';
import 'package:razinshop_rider/gen/assets.gen.dart';
import 'package:razinshop_rider/generated/l10n.dart';
import 'package:razinshop_rider/routers.dart';
import 'package:razinshop_rider/utils/context_less_navigate.dart';
import 'package:razinshop_rider/utils/extensions.dart';
import 'package:razinshop_rider/utils/phone_validator.dart';
import 'package:razinshop_rider/views/auth/layouts/confirm_otp_layout.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark ? Colors.black : AppColor.whiteColor,
      appBar: AppBar(
        backgroundColor: context.isDark ? Colors.black : AppColor.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            Assets.svgs.backArrow,
            color: AppColor.primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Image.asset(
            'delivery.png',
            width: 200.w,
          ),
          Gap(65.h),
          FormBuilder(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).forgotPassword,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gap(12.h),
                  Text(
                    S.of(context).enterRegPhnNumbr,
                    style: TextStyle(
                      color: AppColor.greyColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(24.h),
                  Text(
                    S.of(context).phoneNumber,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Gap(12.h),
                  FormBuilderTextField(
                    name: "phone",
                    keyboardType: TextInputType.phone,
                    decoration: AppTheme.inputDecoration.copyWith(
                      hintText: '0700000000 or 256700000000',
                      helperText: 'Enter Ugandan phone number',
                      hintStyle: TextStyle(
                        color: AppColor.greyColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    validator: (value) {
                      return PhoneValidator.validateUgandanPhone(value, context);
                    },
                    onEditingComplete: () {
                      final value = _formKey.currentState?.fields['phone']?.value;
                      if (value != null && value.isNotEmpty) {
                        final normalizedNumber = PhoneValidator.normalizeUgandanPhone(value);
                        if (normalizedNumber != value) {
                          _formKey.currentState?.fields['phone']?.didChange(normalizedNumber);
                        }
                      }
                    },
                  ),
                  Gap(30.h),
                  // mycustombutton
                  Consumer(
                    builder: (context, ref, child) {
                      final loading = ref.watch(sendOTPProvider);
                      return loading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : MyCustomButton(
                              onTap: () async {
                                if (_formKey.currentState!.saveAndValidate()) {
                                  final phone = _formKey.currentState!.fields['phone']!.value.toString();
                                  final normalizedPhone = PhoneValidator.normalizeUgandanPhone(phone);
                                  
                                  try {
                                    // Try sending OTP to both phone and email
                                    final value = await ref
                                        .read(sendOTPProvider.notifier)
                                        .sendOTP(
                                          phone: normalizedPhone,
                                          isForgetPass: true,
                                          email: null, // We'll get email from backend based on phone
                                          sendToEmail: true,
                                        );
                                    
                                    print("\n--------- OTP RESPONSE ---------");
                                    print("Response: $value");
                                        
                                    if (value['success'] == true) {
                                      if (context.mounted) {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('OTP Sent'),
                                              content: Text('An OTP has been sent to your registered email address.'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context); // Close dialog
                                                    context.nav.pushNamed(
                                                      Routes.confirmOTP,
                                                      arguments: ConfirmOTPScreenArguments(
                                                        phoneNumber: normalizedPhone,
                                                        isPasswordRecover: true,
                                                        userData: {},
                                                        otp: value['otp'],
                                                      ),
                                                    );
                                                  },
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(value['message'] ?? 'Please check your phone number and try again'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    print('Send OTP error: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: ${e.toString()}'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              btnText: S.of(context).sendOTP,
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
