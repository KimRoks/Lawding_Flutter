import '../../domain/core/result.dart';
import '../../domain/entities/feedback.dart' as domain;
import '../../domain/repositories/feedback_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'feedback_api.dart';
import 'feedback_mapper.dart';

class FeedbackRepositoryImpl implements FeedbackRepository {
  final DioClient _client;

  FeedbackRepositoryImpl(this._client);

  @override
  Future<Result<void, NetworkError>> submitFeedback(
    domain.Feedback feedback,
  ) async {
    try {
      // Domain → Data 변환
      final params = feedback.toDataModel();

      final request = FeedbackApi.submitFeedback(params);
      await _client.request(request);

      return const Success(null);
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }
}
