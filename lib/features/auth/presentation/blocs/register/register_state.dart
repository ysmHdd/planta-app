part of 'register_bloc.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterUserPendingState extends RegisterState {}

class RegisterUserSuccessState extends RegisterState {}

class RegisterUserFailState extends RegisterState {
  final String message;

  const RegisterUserFailState({required this.message});

  @override
  List<Object> get props => [message];
}
