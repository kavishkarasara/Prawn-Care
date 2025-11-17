/// This file contains the SignUpScreen widget, which handles customer registration.
/// It provides a form for new customers to create accounts with name, email, password, and mobile number.

import 'package:flutter/material.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/widgets/auth_widgets.dart';

/// A screen for customers to sign up and create new accounts.
/// Handles user registration with validation and navigation back to sign-in screen.
class SignUpScreen extends StatefulWidget {
  /// Constructor for SignUpScreen.
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    final mobileNo = _mobileController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        mobileNo.isEmpty) {
      _showMessage("All fields are required!");
      return;
    }

    // Email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showMessage("Please enter a valid email address!");
      return;
    }

    if (password.length <= 6) {
      _showMessage("Password must be longer than 6 characters!");
      return;
    }

    if (mobileNo.length < 9 || mobileNo.length > 15) {
      _showMessage("Mobile number must be between 9 and 15 digits!");
      return;
    }

    if (password != confirm) {
      _showMessage("Passwords do not match!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.customerSignup(
          name, email, password, confirm, mobileNo);

      _showMessage("Customer registered successfully");
      if (mounted) {
        Navigator.pop(context); // go back after sign up
      }
    } catch (e) {
      _showMessage("Registration failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/images/prawncare.jpg',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 40,
                  left: 10,
                  child: IconButton(
                    iconSize: 50,
                    icon: const Icon(
                      Icons.arrow_circle_left,
                      color: Color.fromARGB(255, 184, 184, 184),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _nameController,
                    hintText: 'Name',
                  ),
                  AuthTextField(
                    controller: _emailController,
                    hintText: 'Email Address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  AuthTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    isPassword: true,
                  ),
                  AuthTextField(
                    controller: _confirmController,
                    hintText: 'Confirm Password',
                    isPassword: true,
                  ),
                  AuthTextField(
                    controller: _mobileController,
                    hintText: 'Mobile Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  AuthButton(
                    onPressed: _register,
                    text: 'Register',
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
