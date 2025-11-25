import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planta_app/core/failures/auth_failures.dart';
import 'package:planta_app/core/failures/failures.dart';
import 'package:planta_app/core/firebase/auth_service.dart';
import 'package:planta_app/core/strings/failures.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/domain/usecases/sign_in_user.dart';
import 'package:planta_app/features/auth/domain/usecases/sign_out_user.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUserUseCase signInUserUseCase;
  final SignOutUserUseCase signOutUserUseCase;
  final AuthService authService;

  AuthBloc({
    required this.signInUserUseCase,
    required this.signOutUserUseCase,
    required this.authService,
  }) : super(AuthInitial()) {
    authService.userStream.listen((user) {
      if (user != null) {
        emit(AuthenticatedState(userId: user.uid));
      } else {
        emit(UnAuthenticatedState());
      }
    });

    on<LoginEvent>((event, emit) async {
      //pending login
      emit(LoginPendingState());
      //login process
      final failureOrDoneLogin = await signInUserUseCase(event.user);

      failureOrDoneLogin.fold((left) {
        emit(AuthErrorState(message: _mapLoginFailureToMessage(left)));
        emit(UnAuthenticatedState());
      }, (_) => emit(AuthenticatedState(userId: authService.currentUser!.uid)));
    });
    on<LogoutEvent>((event, emit) async {
      //pending logout
      emit(LogoutPendingState());
      //process logout
      final failureOrDoneLogOut = await signOutUserUseCase();

      failureOrDoneLogOut.fold((left) {
        emit(AuthErrorState(message: _mapLogOutFailureToMessage(left)));
        emit(AuthenticatedState(userId: authService.currentUser!.uid));
      }, (_) => emit(UnAuthenticatedState()));
    });
  }

  String _mapLoginFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case OfflineFailure:
        return OFFLINE_FAILURE_MESSAGE;
      case SignInWrongPwdFailure:
        return LOGIN_USER_WRONG_PWD;
      case SignInUserNotFoundFailure:
        return LOGIN_USER_NOT_FOUND;
      default:
        return "Erreur inconnue...";
    }
  }

  String _mapLogOutFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case OfflineFailure:
        return OFFLINE_FAILURE_MESSAGE;
      default:
        return "Erreur inconnue...";
    }
  }

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    // TODO: implement mapEventToState
  }
}
