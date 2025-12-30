import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:naira_sms_pulse/core/config/asset/app_icons.dart';
import 'package:naira_sms_pulse/core/config/theme/app_colors.dart';
import 'package:naira_sms_pulse/core/helpers/dimensions.dart';
import 'package:naira_sms_pulse/core/helpers/validators.dart';
import 'package:naira_sms_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_button.dart';
import 'package:naira_sms_pulse/features/auth/presentation/widgets/auth_text_form_field.dart';
import 'package:naira_sms_pulse/features/splash/presentation/widgets/animated_pulse_painter.dart';

class SignInPage extends StatefulWidget {
  static const String routeName = 'sign_in_page';
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    );

    _animationController.forward();
  }

  //GLobal Key
  final _signInFormKey = GlobalKey<FormState>();

  //TextForm Field Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //Show Password Logic
  bool passwordState = true;
  bool showPassword() {
    setState(() {
      passwordState = !passwordState;
    });
    return passwordState;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = Dimensions.screenWidth(context);
    final screenHeight = Dimensions.screenHeight(context);

    final logoWidth = (screenWidth * 0.5).clamp(150, 300);
    final logoHeight = logoWidth / 1.8;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  top: Dimensions.top(context),
                  // bottom: Dimensions.bottom(context),
                ),
                child: Column(
                  children: [
                    //App Logo
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
                    // Text
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.secondaryColor),
                    ),
                    SizedBox(height: 5),
                    //Richtext
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(color: AppColors.secondaryColor),
                        children: [
                          TextSpan(text: 'Stay on Top of your '),
                          TextSpan(
                            text: 'Spending!',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: AppColors.greyAccentColor),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25),

                    //Textformfields
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.horizontal(context),
                      ),
                      child: Form(
                        key: _signInFormKey,
                        child: Column(
                          children: [
                            //Email
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

                            //Password
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
                                    ? Icon(Icons.visibility_outlined, size: 24)
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
                            //Sign In Button
                            AuthButton(
                              backGroundColor: AppColors.secondaryColor,
                              widget: Text(
                                'Sign in',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(color: AppColors.primaryColor),
                              ),
                              borderSide: BorderSide.none,
                              onPressed: () {
                                if (_signInFormKey.currentState!.validate()) {}
                              },
                            ),

                            SizedBox(height: 25),

                            //Other Sign In Options
                            //Google Sign In
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
                            //Apple Sign In
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
                      onTap: () {},
                      child: GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(ShowSignUpEvent());
                        },
                        child: Text(
                          'Sign Up',
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
