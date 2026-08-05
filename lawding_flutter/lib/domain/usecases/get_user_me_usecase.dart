import '../core/result.dart';
import '../entities/user_me.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

class GetUserMeUseCase {
  final UserRepository _repository;

  GetUserMeUseCase(this._repository);

  Future<Result<UserMe, NetworkError>> execute() {
    return _repository.getMe();
  }
}
