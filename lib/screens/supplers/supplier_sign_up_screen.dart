import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/supplers/supplier_sign_in_screen.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/widgets/suppler_sign_up_form.dart';
import 'package:prawn__farm/widgets/supplier_sign_up_header.dart';

class SupplierSignUpScreen extends StatefulWidget {
  const SupplierSignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SupplierSignupScreenState createState() => _SupplierSignupScreenState();
}

class _SupplierSignupScreenState extends State<SupplierSignUpScreen> {
  final _authService = AuthService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Email format validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar("Please enter a valid email address!");
      return;
    }

    if (password.length <= 6) {
      _showSnackBar("Password must be longer than 6 characters!");
      return;
    }

    if (phone.length < 9 || phone.length > 15) {
      _showSnackBar("Phone number must be between 9 and 15 digits!");
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match!");
      return;
    }

    try {
      // ignore: unused_local_variable
      final response = await _authService.supplierSignup(
        name,
        email,
        password,
        confirmPassword,
        phone,
      );

      _showSnackBar("Registration successful!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SupplierSigninScreen(),
        ),
      );
    } on AuthException catch (e) {
      _showSnackBar('Registration failed: ${e.message}');
    } catch (e) {
      _showSnackBar('An unexpected error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SupplierSignupHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SupplierSignupForm(
                nameController: _nameController,
                emailController: _emailController,
                phoneController: _phoneController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                onRegisterPressed: _handleSignUp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
