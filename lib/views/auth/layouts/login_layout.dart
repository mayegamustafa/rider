import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:razinshop_rider/components/my_custom_button.dart';
import 'package:razinshop_rider/config/app_color.dart';
import 'package:razinshop_rider/config/app_text.dart';
import 'package:razinshop_rider/config/theme.dart';
import 'package:razinshop_rider/controllers/auth_controller/auth_controller.dart';
import 'package:razinshop_rider/gen/assets.gen.dart';
import 'package:razinshop_rider/generated/l10n.dart';
import 'package:razinshop_rider/routers.dart';
import 'package:razinshop_rider/utils/context_less_navigate.dart';
import 'package:razinshop_rider/utils/extensions.dart';
import 'package:razinshop_rider/utils/phone_validator.dart';

class LoginLayout extends ConsumerWidget {
  const LoginLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.isDark ? Colors.black : AppColor.whiteColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Gap(65.h),
          Hero(tag: "logo", child: _LogoSection()),
          Gap(50.h),
          Expanded(child: SingleChildScrollView(child: _LoginForm())),
          Gap(20.h),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60.h,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColor.borderColor, width: 1),
          ),
        ),
        child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  S.of(context).dontHaveAccount,
                  style: AppTextStyle.normalBody,
                ),
                TextButton(
                  onPressed: () {
                    context.nav.pushNamed(Routes.registration);
                  },
                  child: Text(
                    S.of(context).registerNow,
                    style: AppTextStyle.normalBody.copyWith(
                      color: AppColor.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            )
            .animate(delay: 500.ms)
            .moveY(
              begin: 40,
              end: 0,
              curve: Curves.easeInOut,
              duration: 200.ms,
            ),
      ),
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<_LoginForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool isPasswordVisible = false;
  @override
  void initState() {
    super.initState();
    // No demo info in fields
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _formKey,
  // initialValue: {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(50.h),
            Center(
              child: Text(
                S.of(context).welcomBack,
                style: AppTextStyle.extraLargeBody,
              ),
            ),
            Gap(24.h),
            Text(S.of(context).phoneNumber, style: AppTextStyle.normalBody),
            Gap(12.h),
            FormBuilderTextField(
              name: "phone",
              keyboardType: TextInputType.phone,
              decoration: AppTheme.inputDecoration.copyWith(
                hintText: '0700000000 or 256700000000',
                helperText: 'Enter Ugandan phone number',
              ),
              validator: (value) {
                return PhoneValidator.validateUgandanPhone(value, context);
              },
              // Using onEditingComplete instead of onChanged to avoid continuous validation
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
            Gap(20.h),
            Text(S.of(context).password, style: AppTextStyle.normalBody),
            Gap(12.h),
            FormBuilderTextField(
              name: "password",
              obscureText: !isPasswordVisible,
              decoration: AppTheme.inputDecoration.copyWith(
                hintText: '',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  icon: Icon(
                    !isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                ),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(),
                FormBuilderValidators.minLength(6),
              ]),
            ),
            Gap(15.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.nav.pushNamed(Routes.forgotPassword);
                },
                child: Text(
                  S.of(context).forgotPassword,
                  style: AppTextStyle.smallBody.copyWith(
                    fontSize: 14.sp,
                    color: context.isDark ? Colors.grey : AppColor.black,
                  ),
                ),
              ),
            ),
            Gap(25.h),
            Consumer(
              builder: (context, ref, child) {
                final loginLoading = ref.watch(loginProvider);
                return loginLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MyCustomButton(
                      btnText: S.of(context).login,
                      onTap: () async {
                        if (_formKey.currentState!.saveAndValidate()) {
                          final formData = _formKey.currentState!.value;
                          try {
                            // Normalize the phone number before sending to API
                            String normalizedPhone = PhoneValidator.normalizeUgandanPhone(formData['phone']);
                            
                            final result = await ref
                                .read(loginProvider.notifier)
                                .login(
                                  phone: normalizedPhone,
                                  password: formData['password'],
                                );
                            
                            if (result == true) {
                              await ref.read(userDetailsProvider.notifier).build();
                              if (context.mounted) {
                                context.nav.pushNamedAndRemoveUntil(
                                  Routes.home,
                                  (route) => false,
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Invalid credentials'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                              ref.invalidate(loginProvider);
                            }
                          } catch (e) {
                            print('Login error: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Login failed: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            ref.invalidate(loginProvider);
                          }
                        }
                        // context.nav.pushNamed(Routes.home);
                      },
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        context.isDark
            ? Assets.pngs.riderAppDark.image(width: 200.w)
            : Assets.pngs.riderApp.image(width: 200.w),
      ],
    );
  }
}
