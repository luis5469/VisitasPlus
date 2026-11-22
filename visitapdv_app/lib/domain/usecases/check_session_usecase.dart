import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

@lazySingleton
class CheckSessionUseCase {
  final AuthRepository _repository;
  CheckSessionUseCase(this._repository);

  Future<(UserEntity?, Failure?)> call() => _repository.getCurrentUser();
}
