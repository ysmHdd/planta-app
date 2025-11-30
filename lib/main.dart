import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart' as di;
import 'core/router/app_router.dart';
import 'core/themes/theme_manager.dart';

import 'features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'features/auth/presentation/blocs/register/register_bloc.dart';
import 'features/plants/presentation/bloc/plant_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<RegisterBloc>()),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<PlantBloc>()),
      ],

      child: MaterialApp.router(
        title: 'Planta',
        debugShowCheckedModeBanner: false,

        theme: AppThemes.appThemeData[AppTheme.lightTheme],

        routerConfig: di.sl<AppRouter>().router,
      ),
    );
  }
}
