import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:planta_app/core/failures/auth_failures.dart';
import 'package:planta_app/core/failures/failures.dart';
import 'package:planta_app/core/strings/failures.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/domain/usecases/register_user.dart';
part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterUserUseCase registerUserUseCase;
  RegisterBloc({required this.registerUserUseCase}) : super(RegisterInitial()) {
    on<RegisterUserEvent>((event, emit) async {
      // traitement en cours
      emit(RegisterUserPendingState());

      final failureOrDoneRegister = await registerUserUseCase(event.user);

      failureOrDoneRegister.fold(
        (left) => emit(
          RegisterUserFailState(message: _mapRegisterFailureToMessage(left)),
        ),
        (_) => emit(RegisterUserSuccessState()),
      );
    });
  }

  String _mapRegisterFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case OfflineFailure:
        return OFFLINE_FAILURE_MESSAGE;
      case RegisterUserWeakPwdFailure:
        return REGISTER_USER_WEAK_PWD;
      case RegisterUserUsedEmailFailure:
        return REGISTER_USER_EMAIL_USED;
      default:
        return "Erreur inconnue...";
    }
  }

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    // TODO: implement mapEventToState
  }
}
