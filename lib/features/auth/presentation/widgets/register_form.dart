import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/features/auth/domain/entities/user_entity.dart';
import 'package:planta_app/features/auth/presentation/blocs/register/register_bloc.dart';
import 'package:planta_app/features/auth/presentation/widgets/auth_btn.dart';
import 'package:validators/validators.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  RegisterFormState createState() {
    return RegisterFormState();
  }
}

class RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  void validateAndRegisterUser() {
    if (_formKey.currentState!.validate()) {
      final user = UserEntity(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _pwdController.text.trim(),
      );

      BlocProvider.of<RegisterBloc>(context).add(RegisterUserEvent(user: user));
    }
  }

  InputDecoration _getInputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Colors.green, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Champ Nom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextFormField(
                  controller: _nameController,
                  decoration: _getInputDecoration(
                    label: 'Entrer votre nom',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom est obligatoire';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _getInputDecoration(
                    label: 'Entrer votre email',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est obligatoire';
                    }
                    if (!isEmail(value)) {
                      return "Format d'email incorrect";
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: TextFormField(
                  controller: _pwdController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: _getInputDecoration(
                    label: 'Entrer votre mot de passe',
                    icon: Icons.lock_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le mot de passe est obligatoire';
                    }
                    if (!isLength(value, 8)) {
                      return "Mot de passe faible: 8 caractères minimum";
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 10),
                child: Column(
                  children: [
                    BlocBuilder<RegisterBloc, RegisterState>(
                      builder: (context, state) {
                        if (state is RegisterUserPendingState) {
                          return const CircularProgressIndicator(
                            color: Colors.green,
                          );
                        } else {
                          return AuthButton(
                            text: "S'INSCRIRE",
                            onPressed: validateAndRegisterUser,
                            color: Colors.green,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthButton(
                      text: "CONNEXION",
                      onPressed: () => GoRouter.of(context).goNamed('login'),
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
