import 'dart:io';

import 'package:vehicle_rental_system/feature/brand/data/model/page_response.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_image_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';

abstract class VehicleRemoteDataSource {
  // Get paginated vehicles with optional Explore filters.
  Future<PageResponse<VehicleModel>> getVehicles({
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

  Future<VehicleModel> getVehicleById(int id);

  // Backend returns a raw List<BookedDateDTO>.
  Future<List<BookedDate>> getVehicleBookedDates(int vehicleId);

  Future<VehicleModel> createVehicle(VehicleModel vehicle);

  Future<VehicleModel> updateVehicle(VehicleModel vehicle);

  Future<void> deleteVehicle(int id);

  // Backend returns a raw list of vehicle images.
  Future<List<VehicleImageModel>> uploadVehicleImages(
    int vehicleId,
    List<File> images,
  );

  Future<void> deleteVehicleImage(int vehicleImageId);

  Future<void> updateVehicleImage(
    int vehicleImageId, {
    required int vehicleId,
    required int attachmentId,
    required bool isPrimary,
    required int displayOrder,
  });
}
