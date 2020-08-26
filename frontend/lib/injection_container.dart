import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/network/socket_service.dart';
import 'features/login/data/datasources/user_local_data_source.dart';
import 'features/login/data/datasources/user_remote_data_source.dart';
import 'features/login/data/repositories/user_repository_impl.dart';
import 'features/login/domain/repositories/user_repository.dart';
import 'features/login/domain/usecases/get_jwt.dart';
import 'features/login/domain/usecases/register.dart';
import 'features/login/domain/usecases/send_verification_code.dart';
import 'features/login/domain/usecases/sign_in.dart';
import 'features/login/domain/usecases/update_password.dart';
import 'features/login/presentation/bloc/bloc.dart';
import 'features/login/presentation/util/login_input_checker.dart';
import 'features/modules/data/datasources/modules_remote_data_source.dart';
import 'features/modules/data/repositories/modules_repository_impl.dart';
import 'features/modules/domain/repositories/modules_repository.dart';
import 'features/modules/domain/usecases/add_favourite_sensor_by_id.dart';
import 'features/modules/domain/usecases/add_module.dart';
import 'features/modules/domain/usecases/configure_wifi.dart';
import 'features/modules/domain/usecases/get_modules.dart';
import 'features/modules/domain/usecases/remove_favourite_sensor_by_id.dart';
import 'features/modules/domain/usecases/update_module_settings.dart';
import 'features/modules/domain/usecases/update_sensor_settings.dart';
import 'features/modules/presentation/bloc/bloc.dart';
import 'features/modules/presentation/util/modules_input_checker.dart';

// sl <=> service locator
final sl = GetIt.instance;

Future<void> initGlobal() async {
//! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
  sl.registerLazySingleton(() => SocketService());
}

//! Features - Login
Future<void> initLoginDI() async {
  sl.registerLazySingleton(() => LoginInputChecker());

//Bloc
  sl.registerFactory(
    () => LoginBloc(
      getJWT: sl(),
      signIn: sl(),
      register: sl(),
      checker: sl(),
      verficiationCode: sl(),
      updatePassword: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetJWT(sl()));
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => Register(sl()));
  sl.registerLazySingleton(() => SendVerificationCode(sl()));
  sl.registerLazySingleton(() => UpdatePassword(sl()));

  // Repository
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<UserLocalDataSource>(
    () => UserLocalDataSourceImpl(sharedPreferences: sl()),
  );
}

//! Features - Modules
Future<void> initModulesDI() async {
  sl.registerLazySingleton(() => ModulesInputChecker());

//Bloc
  sl.registerFactory(
    () => ModuleBloc(
      addModule: sl(),
      getModules: sl(),
      configuration: sl(),
      removeFavouriteSensorById: sl(),
      addFavouriteSensorById: sl(),
      inputChecker: sl(),
      updateSensorSettings: sl(),
      updateModuleSettings: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => AddModule(sl()));
  sl.registerLazySingleton(() => GetModules(sl()));
  sl.registerLazySingleton(() => RemoveFavouriteSensorById(sl()));
  sl.registerLazySingleton(() => AddFavouriteSensorById(sl()));
  sl.registerLazySingleton(() => ConfigureWifi(sl()));
  sl.registerLazySingleton(() => UpdateSensorSettings(sl()));
  sl.registerLazySingleton(() => UpdateModuleSettings(sl()));

  // Repository
  sl.registerLazySingleton<ModulesRepository>(() => ModulesRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Data sources
  sl.registerLazySingleton<ModulesRemoteDataSource>(
    () => ModulesRemoteDataSourceImpl(client: sl()),
  );
}
