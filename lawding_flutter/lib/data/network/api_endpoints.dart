class ApiEndpoints {
  ApiEndpoints._();

  // Annual Leave Calculator
  static const String calculate = '/annual-leaves/calculate';

  // Feedback
  static const String submitFeedback = '/v1/feedback';

  // App Version
  static const String checkVersion = '/v1/app/version-check';

  // Dictionaries
  static const String dictionaries = '/v1/dictionaries';

  // Dictionary Search
  static const String dictionarySearch = '/v1/dictionaries/search';

  // Holidays
  static const String holidays = '/v1/holidays';

  // Auth
  static const String reissue = '/v1/auth/reissue';

  // Calendar Events
  static const String calendarEvents = '/v1/calendar-events';

  // User
  static const String userMe = '/v1/users/me';
  static const String userProfile = '/v1/users/me/profile';
  static const String userDashboard = '/v1/users/me/dashboard';
  static const String leaveSummary = '/v1/users/me/leave-summary';
  static const String leavePolicy = '/v1/users/leave-policy';
  static const String leaveYearlyBalance = '/v1/users/leave-yearly-balance/total-minutes';
  static const String leaveYearlyBalanceLatest = '/v1/users/leave-yearly-balance/latest';

  // Dashboard
  static const String leaveDashboard = '/v1/dashboard/leave';
}
