import 'package:flutter/material.dart';
import 'package:prawn__farm/utils/constants.dart';

class SupplierSigninForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;
  final VoidCallback onSignUpPressed;
  final VoidCallback onForgotPasswordPressed;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;

  const SupplierSigninForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
    required this.onSignUpPressed,
    required this.onForgotPasswordPressed,
    required this.rememberMe,
    required this.onRememberMeChanged,
  });

  @override
  State<SupplierSigninForm> createState() => _SupplierSigninFormState();
}

class _SupplierSigninFormState extends State<SupplierSigninForm> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const Text('Username or Email'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.emailController,
          decoration: InputDecoration(
            hintText: 'Enter Username or Email',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('Password'),
        const SizedBox(height: 8),
        TextField(
          controller: widget.passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: 'Password',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2.5,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: widget.rememberMe,
              onChanged: (value) => widget.onRememberMeChanged(value ?? false),
            ),
            const Text('Remember Me'),
            const Spacer(),
            TextButton(
              onPressed: widget.onForgotPasswordPressed,
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            onPressed: widget.onLoginPressed,
            child: const Text(
              'Log In',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Don't have an Account?"),
            TextButton(
              onPressed: widget.onSignUpPressed,
              child: const Text(
                "Click Here",
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
