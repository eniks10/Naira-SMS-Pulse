import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/alerts.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/helpers/validators.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_button.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_text_form_field.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/loading_overlay.dart';
import 'package:naira_sms_pulse/features/splash/presentation/widgets/animated_pulse_painter.dart';

class SignUpPage extends StatefulWidget {
  static const String routeName = 'sign_up_page';
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  //Animation Controller
  late AnimationController animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    _animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOutQuart,
    );

    animationController.forward();
  }

  //Global form Key
  final _signUpFormKey = GlobalKey<FormState>();

  //Textfield Controller
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    animationController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  bool passwordState = true;

  bool showPassword() {
    setState(() {
      passwordState = !passwordState;
    });
    print(passwordState);
    return passwordState;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Dimensions.screenWidth(context);
    final screenHeight = Dimensions.screenHeight(context);

    final logoWidth = (screenWidth * 0.5).clamp(150, 300);
    final logoHeight = logoWidth / 1.8;
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            AppAlerts.showError(context: context, error: state.error ?? '');
          }

          if (state.isSuccess) {
            AppAlerts.shoeSuccess(context: context, message: 'Welcome!');
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            widget: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody:
                      false, // Key: This tells the sliver "My child is not a list, it's a static layout"
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: Dimensions.top(context),
                      bottom: Dimensions.bottom(context),
                    ),
                    child: Column(
                      children: [
                        //App logo
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(logoWidth, logoHeight),
                              painter: AnimatedPulsePainter(_animation.value),
                            );
                          },
                        ),
                        SizedBox(height: 15),

                        FadeTransition(
                          opacity: _animation,
                          child: Text(
                            'PULSE',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: AppColors.secondaryColor),
                          ),
                        ),

                        SizedBox(height: 25),
                        //Spacer(),

                        // Medium Text
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.secondaryColor),
                        ),

                        SizedBox(height: 5),
                        // Spacer(flex: 1),

                        //Rich Text
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppColors.secondaryColor),
                            children: [
                              TextSpan(text: 'Sign Up! Track your '),
                              TextSpan(
                                text: 'Spending',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.greyAccentColor,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 25),
                        //Spacer(),

                        //Textformfields
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.horizontal(context),
                          ),
                          child: Form(
                            key: _signUpFormKey,
                            child: Column(
                              children: [
                                //Full Name
                                AuthTextFormField(
                                  hintText: '',
                                  controller: fullNameController,
                                  labelText: 'Full Name',
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return Validators.validateFullName(value);
                                  },
                                ),
                                //Email
                                SizedBox(height: 25),
                                AuthTextFormField(
                                  hintText: '',
                                  controller: emailController,
                                  labelText: 'Email',
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return Validators.validateEmail(value);
                                  },
                                ),
                                SizedBox(height: 25),
                                //Passowrd
                                AuthTextFormField(
                                  hintText: '',
                                  controller: passwordController,
                                  labelText: 'Password',
                                  onChanged: (value) {},
                                  validator: (value) {
                                    return Validators.validatePassword(value);
                                  },
                                  isForPassowrd: passwordState,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      showPassword();
                                    },
                                    icon: passwordState
                                        ? Icon(
                                            Icons.visibility_outlined,
                                            size: 24,
                                          )
                                        : Icon(
                                            Icons.visibility_off_outlined,
                                            size: 24,
                                          ),
                                    constraints: BoxConstraints(
                                      minWidth: 48,
                                      minHeight: 48,
                                    ),
                                  ),
                                ),

                                SizedBox(height: 35),

                                //Create Account Button
                                AuthButton(
                                  backGroundColor: AppColors.secondaryColor,
                                  widget: Text(
                                    'Create Accout',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: AppColors.primaryColor,
                                        ),
                                  ),
                                  borderSide: BorderSide.none,
                                  onPressed: () {
                                    if (_signUpFormKey.currentState!
                                        .validate()) {
                                      context.read<AuthBloc>().add(
                                        SignUpEvent(
                                          email: emailController.text.trim(),
                                          password: passwordController.text
                                              .trim(),
                                          fullname: fullNameController.text
                                              .trim(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                SizedBox(height: 25),

                                //Other Sign Up Options

                                //Google Sign Up
                                AuthButton(
                                  backGroundColor: AppColors.greyTextColor,
                                  widget: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Google Icon
                                      SvgPicture.asset(
                                        AppIcons.googleIcon,
                                        color: AppColors.greyAccentColor,
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Continue with Google',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: AppColors.primaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                  borderSide: BorderSide.none,
                                  onPressed: () {},
                                ),
                                SizedBox(height: 25),
                                //Apple Sign Up
                                AuthButton(
                                  backGroundColor: Colors.transparent,
                                  widget: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      //Apple Icon
                                      SvgPicture.asset(
                                        AppIcons.appleIcon,
                                        color: AppColors.secondaryColor,
                                        width: 24,
                                        height: 24,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Continue with Apple',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: AppColors.secondaryColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                  borderSide: BorderSide(
                                    color: AppColors.secondaryColor,
                                    width: 1.5,
                                  ),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ),

                        Spacer(),

                        GestureDetector(
                          onTap: () {
                            context.read<AuthBloc>().add(ShowLoginEvent());
                          },
                          child: Text(
                            'Sign in',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppColors.secondaryColor,
                                  letterSpacing: 4,
                                  decoration: TextDecoration.underline,
                                  decorationStyle: TextDecorationStyle.dashed,
                                  decorationColor: AppColors.secondaryColor,
                                  decorationThickness: 2,
                                  fontSize: 20,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            isLoading: state.isLoading,
          );
        },
      ),
    );
  }
}
