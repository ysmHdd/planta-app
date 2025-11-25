import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/core/firebase/auth_service.dart';
import 'package:planta_app/features/auth/data/models/user_model.dart';

abstract class UserDataSource {
  Future<UserCredential> registerUser(UserModel userModel);
  Future<UserCredential> signInUser(UserModel userModel);
  Future<void> signOutUser();
  Future<void>? updateUserName(String userName);
}

class UserDataSourceImpl implements UserDataSource {
  final AuthService authService;

  UserDataSourceImpl({required this.authService});

  @override
  Future<UserCredential> registerUser(UserModel userModel) {
    return authService.signUpWithEmailAndPassword(
      email: userModel.email!,
      password: userModel.password!,
    );
  }

  @override
  Future<UserCredential> signInUser(UserModel userModel) {
    return authService.signInWithEmailAndPassword(
      email: userModel.email!,
      password: userModel.password!,
    );
  }

  @override
  Future<void> signOutUser() {
    return authService.signOut();
  }

  @override
  Future<void>? updateUserName(String userName) {
    return authService.currentUser?.updateDisplayName(userName);
  }
}
