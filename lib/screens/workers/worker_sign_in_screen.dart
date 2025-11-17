import 'package:flutter/material.dart';
import 'package:prawn__farm/screens/workers/prawn_care_home_page.dart';
import 'package:prawn__farm/services/auth_service.dart';
import 'package:prawn__farm/widgets/common/custom_elevated_button.dart';
import 'package:prawn__farm/widgets/common/custom_text_field.dart';
import 'package:prawn__farm/utils/constants.dart';
import 'package:prawn__farm/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerSignInScreen extends StatefulWidget {
  const WorkerSignInScreen({super.key});

  @override
  State<WorkerSignInScreen> createState() => _WorkerSignInScreenState();
}

class _WorkerSignInScreenState extends State<WorkerSignInScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _userNameOrEmailController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedUserNameOrEmail = prefs.getString('saved_user_name_or_email');
    final savedPassword = prefs.getString('saved_password');

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
      await prefs.setString(
          'saved_user_name_or_email', _userNameOrEmailController.text.trim());
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.remove('saved_user_name_or_email');
      await prefs.remove('saved_password');
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userNameOrEmail = _userNameOrEmailController.text.trim();
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    try {
      final response =
          await _authService.workerLogin(userNameOrEmail, password);

      if (!mounted) return;

      if (response['user'] != null) {
        await _saveCredentials();
        // Save user type for session persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userType', 'worker');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrawnCareHomePage()),
        );
      } else {
        _showMessage('Sign in failed: Invalid credentials');
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _userNameOrEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderImage(),
              const SizedBox(height: kSpacingLarge),
              _buildTitle(),
              const SizedBox(height: kSpacingLarge),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserNameOrEmailField(),
                    const SizedBox(height: kSpacingMedium),
                    _buildPasswordField(),
                    const SizedBox(height: kSpacingSmall),
                    _buildRememberMeAndForgotPassword(),
                    const SizedBox(height: kSpacingLarge),
                    _buildSignInButton(),
                    const SizedBox(height: kSpacingLarge),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/prawncare.jpg',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 40,
          left: 10,
          child: IconButton(
            iconSize: 50,
            icon: const Icon(
              Icons.arrow_circle_left,
              color: kSecondaryColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: kPaddingHorizontal),
      child: Text(
        'Welcome Back!',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: kPrimaryColor,
        ),
      ),
    );
  }

  Widget _buildUserNameOrEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Username or Email',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: kSpacingSmall),
        CustomTextField(
          controller: _userNameOrEmailController,
          hintText: 'Enter your Username or Email',
          validator: validateUserNameOrEmail,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: kSpacingSmall),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Enter your password',
          obscureText: _obscureText,
          validator: validatePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v ?? false),
        ),
        const Text('Remember Me'),
        const Spacer(),
      ],
    );
  }

  Widget _buildSignInButton() {
    return CustomElevatedButton(
      onPressed: _signIn,
      label: 'Log In',
      isLoading: _isLoading,
    );
  }
}
