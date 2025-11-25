part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class LoginPendingState extends AuthState {}

class LogoutPendingState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthenticatedState extends AuthState {
  final String userId;

  const AuthenticatedState({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UnAuthenticatedState extends AuthState {}
