import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:vehicle_rental_system/core/network/api_client.dart';
import 'package:vehicle_rental_system/feature/notification/data/datasource/device_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/notification/data/datasource/device_remote_data_source_impl.dart';
import 'package:vehicle_rental_system/feature/notification/data/datasource/notification_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/notification/data/datasource/notification_remote_data_source_impl.dart';
import 'package:vehicle_rental_system/feature/notification/data/repository/device_repository_impl.dart';
import 'package:vehicle_rental_system/feature/notification/data/repository/notification_repository_impl.dart';
import 'package:vehicle_rental_system/feature/notification/domain/repository/device_repository.dart';
import 'package:vehicle_rental_system/feature/notification/domain/repository/notification_repository.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/get_notifications.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/mark_all_notifications_read.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/mark_notification_read.dart';
import 'package:vehicle_rental_system/feature/notification/domain/usecase/register_device_use_case.dart';

final sl = GetIt.instance;

void notificationInjection() {
  // ============================================================
  // Remote Data Source
  // ============================================================

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl<ApiClient>()),
  );

  sl.registerLazySingleton<DeviceRemoteDataSource>(
    () => DeviceRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // ============================================================
  // Repository
  // ============================================================

  sl.registerLazySingleton<NotificationRepository>(
    () =>
        NotificationRepositoryImpl(remote: sl<NotificationRemoteDataSource>()),
  );

  sl.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(remoteDataSource: sl<DeviceRemoteDataSource>()),
  );

  // ============================================================
  // Use Cases
  // ============================================================

  sl.registerLazySingleton<RegisterDeviceUseCase>(
    () => RegisterDeviceUseCase(repository: sl<DeviceRepository>()),
  );

  sl.registerFactory<GetNotifications>(
    () => GetNotifications(sl<NotificationRepository>()),
  );

  sl.registerFactory<MarkNotificationRead>(
    () => MarkNotificationRead(sl<NotificationRepository>()),
  );

  sl.registerFactory<MarkAllNotificationsRead>(
    () => MarkAllNotificationsRead(sl<NotificationRepository>()),
  );
}
