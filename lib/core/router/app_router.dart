import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/core/router/routes.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:planta_app/features/auth/presentation/screens/profile_screen.dart';
import 'package:planta_app/features/auth/presentation/screens/register_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/add_plant_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/detail_plant_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/edit_plant_screen.dart';
import 'package:planta_app/features/plants/presentation/screens/plants_list_screen.dart';

import 'package:planta_app/features/plants/presentation/widgets/toolbar_action_theme_widget.dart';

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
              title: const Text('Planta 🌱'), // ← CHANGÉ: Nom de l'app
              actions: [
                const ActionThemeButton(),
                IconButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
                    context.go(
                      AppRoutes.login,
                    ); // ← AJOUT: Redirection après logout
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
                    context.go(AppRoutes.plants); // ← CHANGÉ
                    break;
                  case 1:
                    context.go(AppRoutes.profile);
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.eco), // ← CHANGÉ: Icône plantes
                  label: 'Mes Plantes', // ← CHANGÉ: Label
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil', // ← CHANGÉ: Français
                ),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.plants, // ← CHANGÉ: plants au lieu de home
            name: 'plants',
            builder: (context, state) {
              // Récupérer l'userId depuis l'état d'authentification
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthenticatedState) {
                return PlantsListScreen(userId: authState.userId);
              }
              return const PlantsListScreen(userId: ''); // Fallback
            },
          ),
          GoRoute(
            path: AppRoutes.addPlant,
            name: 'add_plant',
            builder: (context, state) {
              // Récupérer l'userId depuis l'état d'authentification
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthenticatedState) {
                return AddPlantScreen(userId: authState.userId);
              }
              return const AddPlantScreen(userId: ''); // Fallback
            },
          ),
          GoRoute(
            path: AppRoutes.detailPlant, // ← CHANGÉ: detail_plant
            name: 'detail_plant',
            builder: (context, state) {
              final plantId = state.pathParameters['id'] ?? '';
              return DetailPlantScreen(plantId: plantId);
            },
          ),
          GoRoute(
            path: AppRoutes.editPlant, // ← CHANGÉ: edit_plant
            name: 'edit_plant',
            builder: (context, state) {
              final plantId = state.pathParameters['id'] ?? '';
              return EditPlantScreen(plantId: plantId);
            },
          ),
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
  if (location.startsWith('/plants')) return 0; // ← CHANGÉ
  if (location.startsWith('/profile')) return 1;
  return 0;
}

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Stream stream) {
    stream.listen((_) => notifyListeners());
  }
}
