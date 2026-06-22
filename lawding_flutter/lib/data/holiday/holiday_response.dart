/// 공휴일 목록 API 응답 모델
/// GET /v1/holidays
class HolidayListApiResponse {
  final String status;
  final String message;
  final List<HolidayItemResponse> data;
  final String timestamp;

  const HolidayListApiResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory HolidayListApiResponse.fromJson(Map<String, dynamic> json) {
    return HolidayListApiResponse(
      status: json['status'] as String,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => HolidayItemResponse.fromJson(item as Map<String, dynamic>))
          .toList(),
      timestamp: json['timestamp'] as String,
    );
  }
}

/// 공휴일 항목 응답 모델
class HolidayItemResponse {
  final String date; // "yyyy-MM-dd"
  final String name;

  const HolidayItemResponse({required this.date, required this.name});

  factory HolidayItemResponse.fromJson(Map<String, dynamic> json) {
    return HolidayItemResponse(
      date: json['date'] as String,
      name: json['name'] as String,
    );
  }
}
