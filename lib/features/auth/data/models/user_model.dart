import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.uid,
    required super.name,
    required super.email,
    required String? profileURL,
    required super.password,
  }) : super(profilURL: profileURL);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      profileURL: json['profileURL'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileURL': profilURL,
      'password': password,
    };
  }

  factory UserModel.fromFirebaseAuth(User user) {
    return UserModel(
      uid: user.uid,
      name: user.displayName!,
      email: user.email!,
      profileURL: user.photoURL,
      password: "",
    );
  }
}
