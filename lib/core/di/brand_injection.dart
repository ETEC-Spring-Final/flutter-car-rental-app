import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:vehicle_rental_system/feature/brand/data/datasource/brand_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/brand/data/datasource/brand_remote_data_source_impl.dart';
import 'package:vehicle_rental_system/feature/brand/data/repository/brand_repository_impl.dart';
import 'package:vehicle_rental_system/feature/brand/domain/repository/brand_repository.dart';
import 'package:vehicle_rental_system/feature/brand/domain/usecase/get_brand_use_case.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';

final sl = GetIt.instance;

void brandInjection() {
  //data source
  sl.registerLazySingleton<BrandRemoteDataSource>(
    () => BrandRemoteDataSourceImpl(sl<Dio>()),
  );

  //repo
  sl.registerLazySingleton<BrandRepository>(
    () => BrandRepositoryImpl(sl<BrandRemoteDataSource>()),
  );

  //usecase
  sl.registerLazySingleton<GetBrandUseCase>(
    () => GetBrandUseCase(sl<BrandRepository>()),
  );

  //bloc
  sl.registerFactory<BrandBloc>(() => BrandBloc(sl<GetBrandUseCase>()));
}
