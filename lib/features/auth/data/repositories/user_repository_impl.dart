import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/core/failures/auth_failures.dart';
import 'package:planta_app/core/failures/failures.dart';
import 'package:planta_app/core/firebase/auth_service.dart';
import 'package:planta_app/core/network/network_info.dart';
import 'package:planta_app/features/auth/data/datasources/user_data_source.dart';
import 'package:planta_app/features/auth/data/models/user_model.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource userDataSource;
  final NetworkInfo networkInfo;
  final AuthService authService;

  UserRepositoryImpl({
    required this.userDataSource,
    required this.networkInfo,
    required this.authService,
  });

  @override
  Future<Either<Failure, Unit>> registerUser(UserEntity user) async {
    UserModel userModel = UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      profileURL: user.profilURL,
      password: user.password,
    );

    if (await networkInfo.isConnected) {
      try {
        final credential = await userDataSource.registerUser(userModel);
        return const Right(unit);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          return Left(RegisterUserWeakPwdFailure());
        } else if (e.code == 'email-already-in-use') {
          return Left(RegisterUserUsedEmailFailure());
        } else {
          return Left(RegisterUserFailure() as Failure);
        }
      } catch (e) {
        return Left(RegisterUserFailure() as Failure);
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signIn(UserEntity user) async {
    UserModel userModel = UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      profileURL: user.profilURL,
      password: user.password,
    );

    if (await networkInfo.isConnected) {
      try {
        final credential = await userDataSource.signInUser(userModel);
        return Right(unit);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return Left(SignInUserNotFoundFailure() as Failure);
        } else if (e.code == 'wrong-password') {
          return Left(SignInWrongPwdFailure() as Failure);
        } else {
          return Left(SignInFailure() as Failure);
        }
      } catch (e) {
        return Left(SignInFailure() as Failure);
      }
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    if (await networkInfo.isConnected) {
      await authService.signOut();
      return Right(unit);
    } else {
      return Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUser(UserEntity user) async {
    UserModel userModel = UserModel(
      uid: user.uid,
      name: user.name,
      email: user.email,
      profileURL: user.profilURL,
      password: user.password,
    );
    if (await networkInfo.isConnected) {
      await authService.currentUser?.updateDisplayName(userModel.name);

      await authService.currentUser?.updatePhotoURL(userModel.profilURL);
      return Right(unit);
    } else {
      return Left(OfflineFailure());
    }
  }
}
