import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class RefreshTokenUseCase {
  final AuthRepository _repository;
  RefreshTokenUseCase(this._repository);

  Future<(UserEntity?, Failure?)> call() => _repository.refreshToken();
}
