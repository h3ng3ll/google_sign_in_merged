import '../entities/auth_session.dart';
import '../repositories/i_auth_repository.dart';

class WatchSessionUseCase {
  const WatchSessionUseCase(this._repository);

  final IAuthRepository _repository;

  Stream<AuthSession?> call() => _repository.watchSession();
}
