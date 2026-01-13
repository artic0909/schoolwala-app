class ApiConstants {
  static const String baseUrl = 'https://schoolwala.info/api';

  // Public Routes
  static const String loginEndpoint = '$baseUrl/login';
  static const String registerEndpoint = '$baseUrl/register';
  static const String classesEndpoint = '$baseUrl/classes';
  static const String storiesEndpoint = '$baseUrl/stories';
  static const String facultiesEndpoint = '$baseUrl/faculties';
  static const String faqsEndpoint = '$baseUrl/faqs';
  static const String aboutUsEndpoint = '$baseUrl/about-us';
  static const String contactUsEndpoint = '$baseUrl/contact-us';
  static const String waverRequestEndpoint = '$baseUrl/waver-request';

  // Password Reset
  static const String forgotPasswordEndpoint = '$baseUrl/password/forgot';
  static const String verifyOtpEndpoint = '$baseUrl/password/verify-otp';
  static const String resetPasswordEndpoint = '$baseUrl/password/reset';

  // Protected Routes (Student)
  static const String logoutEndpoint = '$baseUrl/logout';
  static const String userEndpoint = '$baseUrl/user';
  static const String studentProfileEndpoint = '$baseUrl/student/profile';
  static const String updateProfileEndpoint = '$baseUrl/student/profile/update';
  static const String changePasswordEndpoint =
      '$baseUrl/student/change-password';
  static const String myClassEndpoint = '$baseUrl/student/my-class';
  static const String paymentStoreEndpoint = '$baseUrl/student/payment/store';

  // Dynamic Routes Generators
  static String subjectChaptersEndpoint(String subjectId) =>
      '$baseUrl/student/subject/$subjectId/chapters';
  static String chapterVideosEndpoint(String chapterId) =>
      '$baseUrl/student/chapter/$chapterId/videos';
  static String videoDetailsEndpoint(String chapterId, String videoId) =>
      '$baseUrl/student/video/$chapterId/$videoId';
  static const String likeVideoEndpoint = '$baseUrl/student/video/like';
  static const String feedbackEndpoint = '$baseUrl/student/video/feedback';
  static String practiceTestEndpoint(String videoId) =>
      '$baseUrl/student/video/$videoId/test';
  static const String submitTestEndpoint = '$baseUrl/student/video/test/submit';
}
