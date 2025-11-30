import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:planta_app/core/firebase/auth_service.dart';
import 'package:planta_app/core/network/network_info.dart';
import 'package:planta_app/core/router/app_router.dart';

import 'package:planta_app/features/auth/data/datasources/user_data_source.dart';
import 'package:planta_app/features/auth/data/repositories/user_repository_impl.dart';
import 'package:planta_app/features/auth/domain/repositories/user_repository.dart';
import 'package:planta_app/features/auth/domain/usecases/register_user.dart';
import 'package:planta_app/features/auth/domain/usecases/sign_in_user.dart';
import 'package:planta_app/features/auth/domain/usecases/sign_out_user.dart';
import 'package:planta_app/features/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:planta_app/features/auth/presentation/blocs/register/register_bloc.dart';

import 'package:planta_app/features/plants/data/datasources/plant_data_source.dart';
import 'package:planta_app/features/plants/data/repositories/plant_repository_impl.dart';
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';
import 'package:planta_app/features/plants/domain/usecases/add_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/delete_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/get_plants.dart';
import 'package:planta_app/features/plants/domain/usecases/update_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/water_plant.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';

import 'package:planta_app/firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  sl.registerLazySingleton<AuthService>(
    () => AuthService(FirebaseAuth.instance),
  );
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());

  sl.registerLazySingleton<UserDataSource>(
    () => UserDataSourceImpl(authService: sl()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      userDataSource: sl(),
      networkInfo: sl(),
      authService: sl(),
    ),
  );

  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => SignInUserUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUserUseCase(sl()));

  sl.registerLazySingleton(
    () => AuthBloc(
      signInUserUseCase: sl(),
      signOutUserUseCase: sl(),
      authService: sl(),
    ),
  );

  sl.registerLazySingleton(() => RegisterBloc(registerUserUseCase: sl()));

  sl.registerLazySingleton<PlantDataSource>(() => PlantDataSourceImpl());

  sl.registerLazySingleton<PlantRepository>(
    () => PlantRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton(() => GetPlants(repository: sl()));
  sl.registerLazySingleton(() => AddPlant(repository: sl()));
  sl.registerLazySingleton(() => UpdatePlant(repository: sl()));
  sl.registerLazySingleton(() => DeletePlant(repository: sl()));
  sl.registerLazySingleton(() => WaterPlant(repository: sl()));

  sl.registerLazySingleton(
    () => PlantBloc(
      getPlants: sl(),
      addPlant: sl(),
      updatePlant: sl(),
      deletePlant: sl(),
      waterPlant: sl(),
    ),
  );

  sl.registerLazySingleton(() => AppRouter(authBloc: sl()));
}
