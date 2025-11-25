import 'package:dartz/dartz.dart';
import 'package:planta_app/core/failures/failures.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/domain/repositories/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository userRepository;

  UpdateUserUseCase(this.userRepository);

  Future<Either<Failure, Unit>> call(UserEntity user) async {
    return await userRepository.updateUser(user);
  }
}
