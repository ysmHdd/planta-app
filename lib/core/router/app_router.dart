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
import 'package:planta_app/features/plants/presentation/widgets/toolbar_action_theme_widget.dart';
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
          currentLocation == '/login' || currentLocation == '/register';

      if (authState is UnAuthenticatedState && !loggingIn) {
        return '/login';
      }

      if (authState is AuthenticatedState && loggingIn) {
        return '/plants';
      }

      return null;
    },
    routes: [
      //Shell for main application layout
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Planta 🌱'),
              actions: [
                const ActionThemeButton(),
                IconButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                    context.go(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout),
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
          GoRoute(
            path: AppRoutes.plants,
            name: 'plants',
            builder: (context, state) {
              return const PlantsListScreen(); // ← SUPPRIME le userId
            },
          ),
          GoRoute(
            path: AppRoutes.addPlant,
            name: 'add_plant',
            builder: (context, state) {
              return const AddPlantScreen(); // ← SUPPRIME la logique user
            },
          ),

          // Votre fichier de configuration GoRouter (ex: app_router.dart)

          // ... autres GoRoute ...
          GoRoute(
            // Assurez-vous que la variable AppRoutes.editPlant est bien définie,
            // par exemple : static const String editPlant = '/edit-plant';
            path: AppRoutes.editPlant,
            name: 'edit_plant',
            builder: (context, state) {
              // Tente de récupérer l'objet PlantEntity passé en 'extra'
              final plant = state.extra as PlantEntity?;

              // Gestion d'erreur si la navigation est appelée sans l'objet requis
              if (plant == null) {
                return const Scaffold(
                  body: Center(
                    child: Text(
                      'Erreur: La plante n\'a pas été passée à l\'écran de modification.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              // 💡 CORRECTION ESSENTIELLE : Retourner le widget de l'écran d'édition
              // (Vous devrez importer ce widget)
              return EditPlantScreen(plant: plant);
            },
          ),
          // ... suite des GoRoute ...

          // ... autres GoRoute ...
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
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

int _calculateIndex(String location) {
  if (location.startsWith('/plants')) return 0;
  if (location.startsWith('/profile')) return 1;
  return 0;
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
