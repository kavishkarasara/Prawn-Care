import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/supplers/supplier_mainpage.dart';
import 'package:prawn__farm/screens/supplers/supplier_sign_up_screen.dart';
import 'package:prawn__farm/screens/supplers/supplier_forgot_password.dart';
import 'package:prawn__farm/services/auth_service.dart';

import 'package:prawn__farm/widgets/supplier_sign_in_form.dart';
import 'package:prawn__farm/widgets/supplier_sign_in_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupplierSigninScreen extends StatefulWidget {
  const SupplierSigninScreen({super.key});

  @override
  State<SupplierSigninScreen> createState() => _SupplierSigninScreenState();
}

class _SupplierSigninScreenState extends State<SupplierSigninScreen> {
  final _authService = AuthService();
  final TextEditingController _userNameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUserNameOrEmail = prefs.getString('supplier_user_name_or_email');
    final savedPassword = prefs.getString('supplier_password');

    if (savedUserNameOrEmail != null && savedPassword != null) {
      setState(() {
        _userNameOrEmailController.text = savedUserNameOrEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('supplier_user_name_or_email',
          _userNameOrEmailController.text.trim());
      await prefs.setString('supplier_password', _passwordController.text);
    } else {
      await prefs.remove('supplier_user_name_or_email');
      await prefs.remove('supplier_password');
    }
  }

  @override
  void dispose() {
    _userNameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final userNameOrEmail = _userNameOrEmailController.text.trim();
    final password = _passwordController.text.trim();

    if (userNameOrEmail.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter your username/email and password.');
      return;
    }

    try {
      final response =
          await _authService.supplierLogin(userNameOrEmail, password);

      if (response['user'] != null) {
        // Save user type for session persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userType', 'supplier');
        await _saveCredentials(); // Save credentials if Remember Me is checked

        _showSnackBar('Login successful!');
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => const SupplierMainpage(),
          ),
        );
      } else {
        _showSnackBar('Sign in failed: Invalid credentials');
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {}
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierSignUpScreen(),
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SupplierForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SupplierSigninHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SupplierSigninForm(
                emailController: _userNameOrEmailController,
                passwordController: _passwordController,
                onLoginPressed: _handleSignIn,
                onSignUpPressed: _navigateToSignUp,
                onForgotPasswordPressed: _navigateToForgotPassword,
                rememberMe: _rememberMe,
                onRememberMeChanged: (v) => setState(() => _rememberMe = v),
              ),
            ),
            const SizedBox(height: 175),
          ],
        ),
      ),
    );
  }
}
