import '../core/result.dart';
import '../repositories/user_repository.dart';
import '../../data/network/network_error.dart';

class DeleteAccountUseCase {
  final UserRepository _repository;

  DeleteAccountUseCase(this._repository);

  Future<Result<void, NetworkError>> execute() {
    return _repository.deleteAccount();
  }
}
