import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle_image.dart';

abstract class VehicleRepository {
  // Future<Either<Failure, List<Vehicle>>> getVehicles();
  Future<Either<Failure, PageResponse<Vehicle>>> getVehicles({
    int page = 0,
    int size = 10,
    int? brandId,
    String? type,
    String? transmission,
    String? fuelType,
    double? minPrice,
    double? maxPrice,
    int? seats,
  });
  Future<Either<Failure, Vehicle>> getVehicleById(int id);
  Future<Either<Failure, List<BookedDate>>> getVehicleBookedDates(int id);
  Future<Either<Failure, Vehicle>> createVehicle(Vehicle vehicle);
  Future<Either<Failure, Vehicle>> updateVehicle(Vehicle vehicle);
  Future<Either<Failure, Unit>> deleteVehicle(int id);
  Future<Either<Failure, List<VehicleImage>>> uploadVehicleImages(
    int vehicleId,
    List<File> images,
  );
  Future<Either<Failure, Unit>> deleteVehicleImage(int vehicleImageId);
  Future<Either<Failure, Unit>> updateVehicleImage(
    int vehicleImageId, {
    required int vehicleId,
    required int attachmentId,
    required bool isPrimary,
    required int displayOrder,
  });
}
