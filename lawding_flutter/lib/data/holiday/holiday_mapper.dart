import '../../domain/entities/holiday.dart';
import 'holiday_response.dart';

/// HolidayItemResponse → Holiday 변환
extension HolidayItemResponseMapper on HolidayItemResponse {
  Holiday toDomain() {
    return Holiday(
      date: DateTime.parse(date),
      name: name,
    );
  }
}

/// HolidayListApiResponse → `List<Holiday>` 변환
extension HolidayListApiResponseMapper on HolidayListApiResponse {
  List<Holiday> toDomain() => data.map((item) => item.toDomain()).toList();
}
