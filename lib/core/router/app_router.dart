import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/core/router/routes.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:planta_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:planta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/add_plant_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/edit_plant_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/plants_list_screen.dart';
// NOTE: ToolbarActionThemeWidget est retiré car le thème sombre est retiré.
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.plants,
    refreshListenable: GoRouterRefreshNotifier(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final currentLocation = state.matchedLocation;

      final loggingIn =
          currentLocation == AppRoutes.login ||
          currentLocation == AppRoutes.register;

      if (authState is UnAuthenticatedState && !loggingIn) {
        return AppRoutes.login;
      }

      if (authState is AuthenticatedState && loggingIn) {
        return AppRoutes.plants;
      }

      return null;
    },
    routes: [
      // Shell for main application layout (Réintroduire BottomNavigationBar pour la stabilité)
      ShellRoute(
        builder: (context, state, child) {
          // Fonction locale pour déterminer l'index actif
          int _calculateIndex(String location) {
            if (location.startsWith(AppRoutes.plants)) return 0;
            if (location.startsWith(AppRoutes.profile)) return 1;
            return 0;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Planta 🌱'),
              actions: [
                // Uniquement le bouton de déconnexion pour la stabilité
                IconButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                    context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.power_settings_new),
                ),
              ],
            ),
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _calculateIndex(state.matchedLocation),
              onTap: (index) {
                switch (index) {
                  case 0:
                    context.go(AppRoutes.plants);
                    break;
                  case 1:
                    context.go(AppRoutes.profile);
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco),
                  label: 'Mes Plantes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
          );
        },
        routes: [
          // Liste des plantes (Root of the Shell)
          GoRoute(
            path: AppRoutes.plants,
            name: 'plants',
            builder: (context, state) {
              return const PlantsListScreen();
            },
            // Si vous avez des sous-routes (Détails), elles doivent être ici !
            /* routes: [
              GoRoute(
                path: 'details/:id',
                name: 'plant_details',
                builder: (context, state) => const PlantDetailsScreen(),
              ),
            ]
            */
          ),

          // Ajouter une plante
          GoRoute(
            path: AppRoutes.addPlant,
            name: 'add_plant',
            builder: (context, state) {
              return const AddPlantScreen();
            },
          ),

          // Modifier une plante
          GoRoute(
            path: AppRoutes.editPlant,
            name: 'edit_plant',
            builder: (context, state) {
              final plant = state.extra as PlantEntity?;
              if (plant == null) {
                return const Scaffold(
                  body: Center(child: Text('Erreur: Plant manquante.')),
                );
              }
              return EditPlantScreen(plant: plant);
            },
          ),

          // Profil
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
      // Routes non-protégées (Hors Shell)
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
    ],
  );
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
