import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Authentication Service for Workers, Suppliers, and Customers
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ------------------ 🔹 SHARED AUTH METHODS ------------------
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // After successful sign-in, you should fetch the user's profile
      // to check their role and route them to the correct part of the app.
      // The current code allows sign-in but the app logic should handle
      // role-based redirection.
      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    Map<String, dynamic>? extraProfileData,
    required String role,
  }) async {
    try {
      final signUpRes = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: extraProfileData,
      );

      if (signUpRes.user == null) {
        throw AuthException('Signup failed, please try again');
      }

      final insertData = {
        'id': signUpRes.user!.id, // Use the new user's ID
        'email': email,
        'role': role,
        ...?extraProfileData,
      };

      final profileRes = await _supabase
          .from('profiles')
          .insert(insertData)
          .select()
          .maybeSingle();

      if (profileRes == null) {
        throw AuthException('Profile creation failed');
      }

      return signUpRes;
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.message.contains(
          'duplicate key value violates unique constraint "profiles_email_key"')) {
        throw AuthException(
            'This email is already registered as a different user role.');
      }
      rethrow;
    } catch (e) {
      throw AuthException('Sign up failed: $e');
    }
  }

  // ------------------ 🔹 WORKER AUTH METHODS ------------------
  Future<AuthResponse> signInWithUserId({
    required String userId,
    required String password,
  }) async {
    try {
      final profileRes = await _supabase
          .from('profiles')
          .select('email')
          .eq('user_id', userId)
          .maybeSingle();

      if (profileRes == null || profileRes['email'] == null) {
        throw AuthException('Invalid Worker ID');
      }

      final email = profileRes['email'] as String;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Additional check to ensure the signed-in user has the 'worker' role
      final signedInProfile = await getCurrentUserProfile();
      if (signedInProfile?['role'] != 'worker') {
        await signOut(); // Sign out the user if the role doesn't match
        throw AuthException(
            'You do not have the required permissions to sign in as a worker.');
      }

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Worker sign in failed: $e');
    }
  }

  Future<AuthResponse> signUpWithUserId({
    required String userId,
    required String email,
    required String password,
    Map<String, dynamic>? extraProfileData,
  }) async {
    try {
      final exists = await _supabase
          .from('profiles')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (exists != null) {
        throw AuthException('Worker ID already exists');
      }

      final signUpRes = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'user_id': userId},
      );

      if (signUpRes.user == null) {
        throw AuthException('Signup failed, please try again');
      }

      final insertData = {
        'user_id': userId,
        'email': email,
        'role': 'worker',
        ...?extraProfileData,
      };

      final profileRes = await _supabase
          .from('profiles')
          .insert(insertData)
          .select()
          .maybeSingle();

      if (profileRes == null) {
        throw AuthException('Worker profile creation failed');
      }

      return signUpRes;
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      if (e.message.contains(
          'duplicate key value violates unique constraint "profiles_email_key"')) {
        throw AuthException(
            'This email is already registered as a different user role.');
      }
      rethrow;
    } catch (e) {
      throw AuthException('Worker sign up failed: $e');
    }
  }

  // Custom worker login using backend API
  Future<Map<String, dynamic>> workerLogin(
      String userNameOrEmail, String password) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/login/worker-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userNameOrEmail': userNameOrEmail, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userType', 'worker');
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Login failed');
    }
  }

  // Custom supplier login using backend API
  Future<Map<String, dynamic>> supplierLogin(
      String userNameOrEmail, String password) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/login/supplier-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userNameOrEmail': userNameOrEmail, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userType', 'supplier');
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? error['error'] ?? 'Login failed');
    }
  }

  // Custom customer login using backend API
  Future<Map<String, dynamic>> customerLogin(
      String userNameOrEmail, String password) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/login/customer-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'userNameOrEmail': userNameOrEmail, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userType', 'customer');
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Login failed');
    }
  }

  // Custom supplier signup using backend API
  Future<Map<String, dynamic>> supplierSignup(String name, String email,
      String password, String confirmPassword, String mobileNo) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/signup/supplier-signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'mobile_no': mobileNo,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userType', 'supplier');
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Signup failed');
    }
  }

  // Custom customer signup using backend API
  Future<Map<String, dynamic>> customerSignup(String name, String email,
      String password, String confirmPassword, String mobileNo) async {
    final url = Uri.parse('$BACKEND_BASE_URL/api/signup/customer-signup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'mobile_no': mobileNo,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      await prefs.setString('userType', 'customer');
      await prefs.setString('user', jsonEncode(data['user']));
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? 'Signup failed');
    }
  }

  // Supplier forgot password using backend API
  Future<Map<String, dynamic>> forgotPasswordSupplier(String email) async {
    final url =
        Uri.parse('$BACKEND_BASE_URL/api/mobile/supplier/forgot-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(
          error['message'] ?? error['error'] ?? 'Request failed');
    }
  }

  // Supplier reset password using backend API
  Future<Map<String, dynamic>> resetPasswordSupplier(
      String token, String newPassword) async {
    final url =
        Uri.parse('$BACKEND_BASE_URL/api/mobile/supplier/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw AuthException(error['message'] ?? error['error'] ?? 'Reset failed');
    }
  }

  // ------------------ 🔹 SESSION MANAGEMENT ------------------
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  // ------------------ 🔹 GETTERS ------------------
  User? get currentUser => _supabase.auth.currentUser;
  String? getCurrentUserId() => currentUser?.id;
  bool get isSignedIn => _supabase.auth.currentSession != null;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // ------------------ 🔹 PROFILE HELPERS ------------------
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      return profile;
    } on PostgrestException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to fetch user profile: $e');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    final user = currentUser;
    if (user == null) throw AuthException('No user signed in');

    try {
      await _supabase.from('profiles').update(updates).eq('email', user.email!);
    } on PostgrestException {
      rethrow;
    } catch (e) {
      throw AuthException('Failed to update profile: $e');
    }
  }
}

/// Custom exception class
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
