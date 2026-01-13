class ApiConstants {
  static const String baseUrl = 'https://schoolwala.info/api';

  // ===============================================================================================
  // PUBLIC ROUTES
  // ===============================================================================================

  // Authentication
  static const String loginEndpoint = '$baseUrl/login';
  static const String registerEndpoint = '$baseUrl/register';

  // Common Data
  static const String classesEndpoint = '$baseUrl/classes';
  static const String storiesEndpoint = '$baseUrl/stories';
  static const String facultiesEndpoint = '$baseUrl/faculties';
  static const String faqsEndpoint = '$baseUrl/faqs';
  static const String aboutUsEndpoint = '$baseUrl/about-us';

  // Public Forms
  static const String contactUsEndpoint = '$baseUrl/contact-us';
  static const String waverRequestEndpoint = '$baseUrl/waver-request';

  // Password Reset
  static const String forgotPasswordEndpoint = '$baseUrl/password/forgot';
  static const String verifyOtpEndpoint = '$baseUrl/password/verify-otp';
  static const String resetPasswordEndpoint = '$baseUrl/password/reset';

  // ===============================================================================================
  // PROTECTED ROUTES (Require Authentication)
  // ===============================================================================================

  // Authentication
  static const String logoutEndpoint = '$baseUrl/logout';
  static const String userEndpoint = '$baseUrl/user';

  // -----------------------------------------------
  // Student Profile Management
  // -----------------------------------------------
  static const String studentProfileEndpoint = '$baseUrl/student/profile';
  static const String updateProfileEndpoint = '$baseUrl/student/profile/update';
  static const String changePasswordEndpoint = '$baseUrl/student/change-password';

  // -----------------------------------------------
  // CLASS → SUBJECTS → CHAPTERS → VIDEOS Hierarchy
  // -----------------------------------------------
  
  /// Get student's registered class with all subjects
  static const String myClassEndpoint = '$baseUrl/student/my-class';
  
  /// Get chapters for a specific subject (with lock status)
  /// Usage: subjectChaptersEndpoint('5')
  static String subjectChaptersEndpoint(String subjectId) =>
      '$baseUrl/student/subject/$subjectId/chapters';
  
  /// Get videos for a specific chapter (access control applied)
  /// Usage: chapterVideosEndpoint('12')
  static String chapterVideosEndpoint(String chapterId) =>
      '$baseUrl/student/chapter/$chapterId/videos';

  // -----------------------------------------------
  // Video Interaction
  // -----------------------------------------------
  
  /// Get video details with feedbacks
  /// Usage: videoDetailsEndpoint('12', '25') - chapterId included for consistency
  static String videoDetailsEndpoint(String chapterId, String videoId) =>
      '$baseUrl/student/video/$videoId';
  
  /// Like a video (POST with video_id in body)
  static const String likeVideoEndpoint = '$baseUrl/student/video/like';
  
  /// Submit feedback (POST with video_id, rating, feedback in body)
  static const String feedbackEndpoint = '$baseUrl/student/video/feedback';

  // -----------------------------------------------
  // Practice Test
  // -----------------------------------------------
  
  /// Get practice test questions for a video
  /// Usage: practiceTestEndpoint('25')
  static String practiceTestEndpoint(String videoId) =>
      '$baseUrl/student/video/$videoId/test';
  
  /// Submit test answers (POST with video_id, answers array in body)
  static const String submitTestEndpoint = '$baseUrl/student/video/test/submit';

  // -----------------------------------------------
  // Subscription & Payment
  // -----------------------------------------------
  
  /// Get payment/fees information
  static const String paymentInfoEndpoint = '$baseUrl/student/payment/info';
  
  /// Submit payment receipt (POST with multipart form data)
  static const String paymentStoreEndpoint = '$baseUrl/student/payment/store';
}