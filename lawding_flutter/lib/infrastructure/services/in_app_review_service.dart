import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewService {
  static final InAppReviewService _instance = InAppReviewService._internal();
  factory InAppReviewService() => _instance;
  InAppReviewService._internal();

  static const String _keyLastRequestedAt = 'review_last_requested_at';
  static const String _keyDictionaryExpandCount = 'review_dictionary_expand_count';

  // 재요청 금지 기간 (일)
  static const int _cooldownDays = 3;

  // 용어사전 아이템 펼치기 임계값
  static const int _expandThreshold = 3;

  /// 계산 결과 화면 '처음으로' 버튼 클릭 시 호출
  Future<void> onResultScreenHome() async {
    await _requestReviewIfEligible();
  }

  /// 용어사전 아이템 펼치기 시 호출 — 누적 3회 달성 시 리뷰 요청
  Future<void> onDictionaryItemExpanded() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_keyDictionaryExpandCount) ?? 0) + 1;
    await prefs.setInt(_keyDictionaryExpandCount, count);

    if (count >= _expandThreshold) {
      await _requestReviewIfEligible();
    }
  }

  /// 쿨다운 조건 확인 후 리뷰 요청
  Future<void> _requestReviewIfEligible() async {
    if (!await _isEligible()) return;

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return;

    await inAppReview.requestReview();
    await _recordRequest();
  }

  /// 마지막 요청으로부터 3일 이상 경과했는지 확인
  Future<bool> _isEligible() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRequestedAt = prefs.getInt(_keyLastRequestedAt);

    // 요청 이력 없으면 바로 가능
    if (lastRequestedAt == null) return true;

    final lastRequested = DateTime.fromMillisecondsSinceEpoch(lastRequestedAt);
    return DateTime.now().difference(lastRequested).inDays >= _cooldownDays;
  }

  /// 리뷰 요청 시각 저장 및 카운터 초기화
  Future<void> _recordRequest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastRequestedAt, DateTime.now().millisecondsSinceEpoch);
    await prefs.remove(_keyDictionaryExpandCount);
  }
}
