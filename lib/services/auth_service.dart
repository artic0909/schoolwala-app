import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static final ValueNotifier<Map<String, dynamic>?> userNotifier =
      ValueNotifier(null);

  // Initialize shared preferences and notifier
  static Future<void> init() async {
    final user = await getCurrentUser();
    if (user != null && !user.containsKey('student')) {
      // Data migration: wrap old student object in the new nested structure
      userNotifier.value = {'student': user};
    } else {
      userNotifier.value = user;
    }
  }

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
        if (data['data'] != null) {
          final prefs = await SharedPreferences.getInstance();
          if (data['data']['token'] != null) {
            await prefs.setString(_tokenKey, data['data']['token']);
            print('AuthService: Token saved: ${data['data']['token']}');
          }
          await prefs.setString(_userKey, json.encode(data['data']));
          userNotifier.value = data['data'];
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
        if (responseData['data'] != null) {
          final prefs = await SharedPreferences.getInstance();
          if (responseData['data']['token'] != null) {
            await prefs.setString(_tokenKey, responseData['data']['token']);
          }
          await prefs.setString(_userKey, json.encode(responseData['data']));
          userNotifier.value = responseData['data'];
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
      userNotifier.value = null;
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
        if (data['data'] != null) {
          final user = data['data'];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, json.encode(user));
          userNotifier.value = user;
        }
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

  // ===============================================================================================
  // PROFILE METHODS
  // ===============================================================================================

  // Get Profile Data
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/student/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'];
        if (userData != null) {
          // Store the whole data map (student, profile, class_details)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, json.encode(userData));
          userNotifier.value = userData;
        }
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    List<String>? interests,
    String? imagePath,
  }) async {
    try {
      final headers = await getAuthHeaders();
      headers.remove('Content-Type'); // Important for multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/student/profile/update'),
      );

      request.headers.addAll(headers);

      if (name != null) {
        request.fields['student_name'] = name;
      }

      if (interests != null) {
        // Send as array
        for (int i = 0; i < interests.length; i++) {
          request.fields['interest_in[$i]'] = interests[i];
        }
      }

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', imagePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        final data = json.decode(response.body);
        final userData = data['data'];
        if (userData != null) {
          // If updated profile is returned, sync it
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, json.encode(userData));
          userNotifier.value = userData;
        }
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Failed to update profile'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/student/change-password'),
        headers: headers,
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
