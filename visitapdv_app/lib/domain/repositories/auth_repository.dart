import '../entities/user_entity.dart';
import '../../core/error/failures.dart';

abstract class AuthRepository {
  Future<(UserEntity?, Failure?)> login(String usernameOrEmail, String password);
  Future<(UserEntity?, Failure?)> refreshToken();
  Future<(UserEntity?, Failure?)> getCurrentUser();
  Future<void> logout();
}
