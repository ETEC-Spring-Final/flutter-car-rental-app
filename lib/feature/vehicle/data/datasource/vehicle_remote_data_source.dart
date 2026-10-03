import 'dart:io';

import 'package:vehicle_rental_system/feature/brand/data/model/brand_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_image_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';

abstract class VehicleRemoteDataSource {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> getVehicleById(int id);
  Future<List<BookedDate>> getVehicleBookedDates(int vehicleId);
  Future<VehicleModel> createVehicle(VehicleModel vehicle);
  Future<VehicleModel> updateVehicle(VehicleModel vehicle);
  Future<void> deleteVehicle(int id);
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
