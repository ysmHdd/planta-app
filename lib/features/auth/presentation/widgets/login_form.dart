import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/widgets/auth_btn.dart';
import 'package:validators/validators.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void validateAndLoginUser() {
    if (_formKey.currentState!.validate()) {
      final user = UserEntity(
        name: "",
        email: _emailController.text.trim(),
        password: _pwdController.text.trim(),
      );

      BlocProvider.of<AuthBloc>(context).add(LoginEvent(user: user));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Adresse e-mail',
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Colors.blue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'L\'e-mail est obligatoire';
                }
                if (!isEmail(value)) {
                  return "Format d'e-mail incorrect";
                }
                return null;
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: TextFormField(
              controller: _pwdController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est obligatoire';
                }
                return null;
              },
            ),
          ),

          // Zone des Boutons
          Padding(
            padding: const EdgeInsets.only(top: 30, left: 24, right: 24),
            child: Column(
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is LoginPendingState) {
                      return const CircularProgressIndicator(
                        color: Colors.blue,
                      );
                    } else {
                      return AuthButton(
                        text: "CONNEXION",
                        onPressed: validateAndLoginUser,
                        color: Colors.blue,
                      );
                    }
                  },
                ),

                const SizedBox(height: 16),

                AuthButton(
                  text: "INSCRIPTION",
                  onPressed: () => GoRouter.of(context).goNamed('register'),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
