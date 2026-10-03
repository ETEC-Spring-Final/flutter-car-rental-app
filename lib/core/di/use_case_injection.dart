import 'package:get_it/get_it.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/repository/location_repository.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/usecase/get_location_name.dart';

final sl = GetIt.instance;

void registerUseCases() {
  // ==========================================
  // Authentication
  // ==========================================

  // sl.registerFactory<LoginUseCase>(
  //   () => LoginUseCase(
  //     sl(),
  //   ),
  // );

  // ==========================================
  // Vehicle
  // ==========================================

  sl.registerLazySingleton<GetLocationName>(
    () => GetLocationName(repository: sl<LocationRepository>()),
  );

  // sl.registerFactory<GetVehiclesUseCase>(
  //   () => GetVehiclesUseCase(
  //     sl(),
  //   ),
  // );

  // sl.registerFactory<GetVehicleByIdUseCase>(
  //   () => GetVehicleByIdUseCase(
  //     sl(),
  //   ),
  // );

  // ==========================================
  // Booking
  // ==========================================

  // sl.registerFactory<GetBookings>(() => GetBookings(sl<BookingRepository>()));

  // sl.registerFactory<CreateBooking>(
  //   () => CreateBooking(sl<BookingRepository>()),
  // );
}
