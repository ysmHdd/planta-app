// features/auth/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // EN-TÊTE
              Row(
                children: [
                  Icon(Icons.person, size: 28, color: Colors.green[800]),
                  const SizedBox(width: 12),
                  Text(
                    'Mon Profil',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // CARTE PROFIL SIMPLE
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
                child: Column(
                  children: [
                    // AVATAR
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.green[600],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NOM
                    Text(
                      user?.displayName ?? 'Jardinier',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // EMAIL
                    Text(
                      user?.email ?? 'Non connecté',
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // BOUTON DÉCONNEXION SEULEMENT
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red[600]),
                  title: Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: Colors.red[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
