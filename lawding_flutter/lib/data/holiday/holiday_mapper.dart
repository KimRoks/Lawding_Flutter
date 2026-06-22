import '../../domain/entities/holiday.dart';
import 'holiday_response.dart';

/// HolidayItemResponse → Holiday 변환
extension HolidayItemResponseMapper on HolidayItemResponse {
  Holiday toDomain() {
    final parts = date.split('-');
    return Holiday(
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      name: name,
    );
  }
}

/// HolidayListApiResponse → `List<Holiday>` 변환
extension HolidayListApiResponseMapper on HolidayListApiResponse {
  List<Holiday> toDomain() => data.map((item) => item.toDomain()).toList();
}
