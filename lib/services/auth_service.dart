import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    print('AuthService: Details retrieved token: $token');
    return token;
  }

  // Get Auth Headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        body: {'email': email, 'password': password},
        headers: {'Accept': 'application/json'},
      );

      print('Login Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Save Token and User Data
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, data['token']);
          print('AuthService: Token saved: ${data['token']}');
          if (data['user'] != null) {
            await prefs.setString(_userKey, json.encode(data['user']));
          }
        }

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Invalid credentials or server error',
        };
      }
    } catch (e) {
      print('Login Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        body: data,
        headers: {'Accept': 'application/json'},
      );

      print('Register Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);

        // Save Token and User Data if provided on registration
        if (responseData['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, responseData['token']);
          if (responseData['user'] != null) {
            await prefs.setString(_userKey, json.encode(responseData['user']));
          }
        }

        return {'success': true, 'data': responseData};
      } else {
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Registration failed',
          };
        } catch (_) {
          return {
            'success': false,
            'message':
                'Registration failed with status code ${response.statusCode}',
          };
        }
      }
    } catch (e) {
      print('Register Error: $e');
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Logout
  static Future<bool> logout() async {
    try {
      final headers = await getAuthHeaders();
      await http.post(Uri.parse(ApiConstants.logoutEndpoint), headers: headers);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      return true;
    } catch (e) {
      print('Logout Error: $e');
      return false; // Still return false, but we might want to clear local data anyway
    }
  }

  // Get Current User (Local)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return json.decode(userStr);
    }
    return null;
  }

  // Fetch User from API
  static Future<Map<String, dynamic>> fetchUser() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.userEndpoint),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userKey, json.encode(data));
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch user'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.forgotPasswordEndpoint),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP sent successfully'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.verifyOtpEndpoint),
        body: {'email': email, 'otp': otp},
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'OTP verified'};
      } else {
        final data = json.decode(response.body);
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String confirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.resetPasswordEndpoint),
        body: {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': confirmation,
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password reset successful'};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
