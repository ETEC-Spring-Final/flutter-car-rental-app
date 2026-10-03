import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vehicle_rental_system/feature/favorite/data/datasource/favorite_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/favorite/data/datasource/favorite_remote_data_source_impl.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/datasource/location_remote_data_source.dart';

final sl = GetIt.instance;

void registerDataSource() {
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(sl<Dio>()),
  );
}
