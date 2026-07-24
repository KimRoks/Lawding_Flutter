import '../core/result.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

class UpdateProfileUseCase {
  final UserRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Result<void, NetworkError>> execute({required String nickname}) {
    return _repository.updateProfile(nickname: nickname);
  }
}
