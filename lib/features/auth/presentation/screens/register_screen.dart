// features/auth/presentation/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/core/utils/snack_bar_message.dart';
import 'package:planta_app/features/auth/presentation/blocs/register/register_bloc.dart';
import 'package:planta_app/features/auth/presentation/widgets/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterUserSuccessState) {
          GoRouter.of(context).goNamed('login');
        }
        if (state is RegisterUserFailState) {
          SnackBarMessage().showErrorSnackBar(
            message: state.message,
            context: context,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F8E9),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // EN-TÊTE SIMPLE
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.green[800]),
                    ),
                    Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ICÔNE
                Icon(Icons.forest, size: 60, color: Colors.green[700]),

                const SizedBox(height: 8),

                Text(
                  'Commencez votre aventure jardinage',
                  style: TextStyle(color: Colors.green[600]),
                ),

                const SizedBox(height: 32),

                // FORMULAIRE
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const RegisterForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
