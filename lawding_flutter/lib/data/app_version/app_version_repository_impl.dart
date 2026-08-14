import '../../domain/core/result.dart';
import '../../domain/models/app_version_info.dart';
import '../../domain/repositories/app_version_repository.dart';
import '../network/dio_client.dart';
import '../network/network_error.dart';
import 'app_version_api.dart';

class AppVersionRepositoryImpl implements AppVersionRepository {
  final DioClient _client;

  AppVersionRepositoryImpl(this._client);

  @override
  Future<Result<AppVersionInfo, NetworkError>> checkVersion({
    required String platform,
    required String currentVersion,
  }) async {
    try {
      final request = AppVersionApi.checkVersion(
        platform: platform,
        clientVersion: currentVersion,
      );

      final response = await _client.request(request);
      final versionInfo = AppVersionInfo.fromJson(response.data as Map<String, dynamic>);

      return Success(versionInfo);
    } on NetworkError catch (error) {
      return Failure(error);
    } catch (e) {
      return Failure(ServerError(message: e.toString()));
    }
  }
}
