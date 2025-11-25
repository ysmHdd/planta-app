import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/core/router/app_router.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/blocs/register/register_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/blocs/switchtheme_cubit.dart';
import 'package:planta_app/core/themes/theme_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ⚠️ AJOUTE CETTE LIGNE OBLIGATOIRE
  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<SwitchthemeCubit>(),
        ), // ← UTILISE GETIT ICI AUSSI
        BlocProvider(create: (context) => di.sl<RegisterBloc>()),
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => di.sl<PlantBloc>()),
      ],
      child: BlocBuilder<SwitchthemeCubit, bool>(
        builder: (context, isDarkMode) {
          return MaterialApp.router(
            title: 'Planta',
            debugShowCheckedModeBanner: false,
            theme: isDarkMode
                ? AppThemes.appThemeData[AppTheme.darkTheme]
                : AppThemes.appThemeData[AppTheme.lightTheme],
            routerConfig: di.sl<AppRouter>().router,
          );
        },
      ),
    );
  }
}
