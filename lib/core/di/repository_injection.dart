import 'package:get_it/get_it.dart';
import 'package:vehicle_rental_system/feature/favorite/data/datasource/favorite_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/favorite/data/repository/favorite_repository_impl.dart';
import 'package:vehicle_rental_system/feature/favorite/domain/repository/favorite_repository.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/datasource/location_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/repository/location_repository_impl.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/repository/location_repository.dart';

final sl = GetIt.instance;

void registerRepositories() {
  // ==========================================
  // Authentication
  // ==========================================

  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     sl(),
  //   ),
  // );

  // ==========================================
  // Vehicle
  // ==========================================

  // ==========================================
  // Favorite
  // ==========================================

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<FavoriteRemoteDataSource>()),
  );

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: sl<LocationRemoteDataSource>(),
    ),
  );
}
