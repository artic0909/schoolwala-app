import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class CommonService {
  // Get Classes
  static Future<List<dynamic>> getClasses() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.classesEndpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming data is a list or has a 'data' key which is a list
        if (data is List) return data;
        if (data['data'] is List) return data['data'];
        return [];
      }
      return [];
    } catch (e) {
      print('Get Classes Error: $e');
      return [];
    }
  }

  // Get Stories
  static Future<List<dynamic>> getStories() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.storiesEndpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        if (data['data'] is List) return data['data'];
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get Faculties
  static Future<List<dynamic>> getFaculties() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.facultiesEndpoint),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        if (data['data'] is List) return data['data'];
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get FAQs
  static Future<List<dynamic>> getFAQs() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.faqsEndpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) return data;
        if (data['data'] is List) return data['data'];
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Get About Us
  static Future<String> getAboutUs() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.aboutUsEndpoint));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'] ??
            data['data'] ??
            ''; // Adjust based on actual response
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  // Contact Us Submit
  static Future<Map<String, dynamic>> contactUs(
    String name,
    String email,
    String message,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.contactUsEndpoint),
        body: {'name': name, 'email': email, 'message': message},
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Message sent successfully'};
      }
      return {'success': false, 'message': 'Failed to send message'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
