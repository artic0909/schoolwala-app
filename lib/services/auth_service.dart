import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        body: {'email': email, 'password': password},
      );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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
      );

      print('Register Response Status: ${response.statusCode}');
      print('Register Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
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
}
