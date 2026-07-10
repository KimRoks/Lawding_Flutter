import '../../data/network/network_error.dart';
import '../core/result.dart';
import '../entities/user_profile.dart';
import '../repositories/user_repository.dart';

class GetUserProfileUseCase {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Result<UserProfile, NetworkError>> execute() {
    return _repository.getProfile();
  }
}
