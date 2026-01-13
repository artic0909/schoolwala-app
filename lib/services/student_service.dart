import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

class StudentService {
  // Get Profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.studentProfileEndpoint),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch profile'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, String> data,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.updateProfileEndpoint),
        body: data,
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to update profile'};
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
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.changePasswordEndpoint),
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        },
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully'};
      }
      return {'success': false, 'message': 'Failed to change password'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get My Class (Subjects)
  static Future<Map<String, dynamic>> getMyClass() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.myClassEndpoint),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch classes'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Subject Chapters
  static Future<Map<String, dynamic>> getChapters(String subjectId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.subjectChaptersEndpoint(subjectId)),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch chapters'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Chapter Videos
  static Future<Map<String, dynamic>> getVideos(String chapterId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.chapterVideosEndpoint(chapterId)),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch videos'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Video Details
  static Future<Map<String, dynamic>> getVideoDetails(
    String chapterId,
    String videoId,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.videoDetailsEndpoint(chapterId, videoId)),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch video details'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Like Video
  static Future<Map<String, dynamic>> likeVideo(String videoId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.likeVideoEndpoint),
        body: {'video_id': videoId},
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to like video'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Submit Feedback
  static Future<Map<String, dynamic>> submitFeedback(
    String videoId,
    String feedback,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse(ApiConstants.feedbackEndpoint),
        body: {'video_id': videoId, 'feedback': feedback},
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Feedback submitted'};
      }
      return {'success': false, 'message': 'Failed to submit feedback'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Get Practice Test
  static Future<Map<String, dynamic>> getPracticeTest(String videoId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse(ApiConstants.practiceTestEndpoint(videoId)),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to fetch test'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Submit Practice Test
  static Future<Map<String, dynamic>> submitPracticeTest(
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      // Need to encode body as JSON because it's complex data usually
      headers['Content-Type'] = 'application/json';
      final response = await http.post(
        Uri.parse(ApiConstants.submitTestEndpoint),
        body: json.encode(data),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {'success': false, 'message': 'Failed to submit test'};
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Store Payment
  // Store Payment with Image Upload
  static Future<Map<String, dynamic>> storePayment(
    Map<String, String> fields,
    File imageFile,
  ) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final uri = Uri.parse(ApiConstants.paymentStoreEndpoint);

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Add fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add image
      var pic = await http.MultipartFile.fromPath('receipt', imageFile.path);
      request.files.add(pic);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      }
      return {
        'success': false,
        'message':
            'Failed to store payment: ${response.statusCode} ${response.body}',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
