/// This file contains the CustomerSignin widget, which handles customer authentication.
/// It provides a login form with email/password fields, remember me functionality, and navigation to forgot password and signup screens.

import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/customers/customer_for_pass.dart';
import 'package:prawn__farm/screens/customers/customer_mainpage.dart';
import 'package:prawn__farm/screens/customers/customer_signup.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/widgets/auth_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A screen for customers to sign in to their accounts.
/// Handles authentication, credential saving, and navigation to other auth-related screens.
class CustomerSignin extends StatefulWidget {
  /// Constructor for CustomerSignin.
  const CustomerSignin({super.key});

  @override
  State<CustomerSignin> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<CustomerSignin> {
  final AuthService _authService = AuthService();
  bool _loading = false;
  bool _rememberMe = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('customer_email');
    final savedPassword = prefs.getString('customer_password');

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('customer_email', _emailController.text.trim());
      await prefs.setString('customer_password', _passwordController.text);
    } else {
      await prefs.remove('customer_email');
      await prefs.remove('customer_password');
    }
  }

  Future<void> _signIn() async {
    setState(() => _loading = true);

    try {
      await _authService.customerLogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await _saveCredentials(); // Save credentials if Remember Me is checked

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerMainpage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;
          bool isSmallScreen = screenWidth < 600;

          return Column(
            children: [
              // Top part: Image
              Expanded(
                flex: 1,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.lightBlueAccent.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Image.asset(
                          'assets/images/prawncare.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: screenHeight * 0.05,
                      left: screenWidth * 0.03,
                      child: IconButton(
                        iconSize: isSmallScreen ? 30 : 40,
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.blue,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom part: Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome!',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      AuthTextField(
                        controller: _emailController,
                        hintText: 'Email or Username',
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        isPassword: true,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Row(
                        children: [
                          RememberMeCheckbox(
                            value: _rememberMe,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CustomerForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: isSmallScreen ? 14 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      AuthButton(
                        onPressed: _signIn,
                        text: 'Log In',
                        isLoading: _loading,
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an Account?",
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Click Here",
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
