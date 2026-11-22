import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  Future<(UserEntity?, Failure?)> call({
    required String usernameOrEmail,
    required String password,
  }) => _repository.login(usernameOrEmail, password);
}
