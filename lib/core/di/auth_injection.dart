import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:vehicle_rental_system/core/storage/secure_storage_service.dart';
import 'package:vehicle_rental_system/feature/auth/data/datasource/auth_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:vehicle_rental_system/feature/auth/data/repository/auth_repository_impl.dart';
import 'package:vehicle_rental_system/feature/auth/data/service/oauth2_service_impl.dart';
import 'package:vehicle_rental_system/feature/auth/domain/repository/auth_repository.dart';
import 'package:vehicle_rental_system/feature/auth/domain/service/oauth2_service.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/forgot_password_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/login_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/register_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/domain/usecase/reset_password_use_case.dart';
import 'package:vehicle_rental_system/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/register_device_use_case.dart';

final sl = GetIt.instance;

void authInjection() {
  // dio

  // data
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );

  // repo
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<SecureStorageService>(),
    ),
  );
  // use case
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<OAuth2Service>(() => OAuth2ServiceImpl());

  // bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      resetPasswordUseCase: sl<ResetPasswordUseCase>(),
      registerDeviceUseCase: sl<RegisterDeviceUseCase>(),
      secureStorage: sl<FlutterSecureStorage>(),
      oauth2Service: sl<OAuth2Service>(),
    ),
  );
}
