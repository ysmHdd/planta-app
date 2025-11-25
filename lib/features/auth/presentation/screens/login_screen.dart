import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/core/utils/snack_bar_message.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          SnackBarMessage().showErrorSnackBar(
            message: state.message,
            context: context,
          );
        }
      },
      child: Scaffold(body: LoginForm()),
    );
  }
}
