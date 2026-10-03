import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/feature/brand/data/model/page_response.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/datasource/vehicle_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/mapper/vehicle_image_mapper.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/mapper/vehicle_mapper.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle_image.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/repository/vehicle_repository.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource remote;

  VehicleRepositoryImpl(this.remote);

  // @override
  // Future<Either<Failure, List<Vehicle>>> getVehicles() async {
  //   try {
  //     final models = await remote.getVehicles();

  //     final vehicles = models.map(VehicleMapper.toEntity).toList();

  //     return Right(vehicles);
  //   } catch (e) {
  //     return Left(ServiceFailure(e.toString()));
  //   }
  // }
  @override
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
  }) async {
    try {
      final response = await remote.getVehicles(
        page: page,
        size: size,
        brandId: brandId,
        type: type,
        transmission: transmission,
        fuelType: fuelType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        seats: seats,
      );

      final vehicles = response.content.map(VehicleMapper.toEntity).toList();

      return Right(
        PageResponse<Vehicle>(
          content: vehicles,
          page: response.page,
          size: response.size,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          first: response.first,
          last: response.last,
        ),
      );
    } catch (e) {
      return Left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> getVehicleById(int id) async {
    try {
      final model = await remote.getVehicleById(id);
      final vehicle = VehicleMapper.toEntity(model);

      return right(vehicle);
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookedDate>>> getVehicleBookedDates(
    int id,
  ) async {
    try {
      final dates = await remote.getVehicleBookedDates(id);

      return right(dates);
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> createVehicle(Vehicle vehicle) async {
    try {
      final model = await remote.createVehicle(VehicleMapper.toModel(vehicle));

      return right(VehicleMapper.toEntity(model));
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> updateVehicle(Vehicle vehicle) async {
    try {
      final model = await remote.updateVehicle(VehicleMapper.toModel(vehicle));

      return right(VehicleMapper.toEntity(model));
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicle(int id) async {
    try {
      await remote.deleteVehicle(id);

      return right(unit);
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<VehicleImage>>> uploadVehicleImages(
    int vehicleId,
    List<File> images,
  ) async {
    try {
      final models = await remote.uploadVehicleImages(vehicleId, images);

      return right(models.map(VehicleImageMapper.toEntity).toList());
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVehicleImage(int vehicleImageId) async {
    try {
      await remote.deleteVehicleImage(vehicleImageId);

      return right(unit);
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateVehicleImage(
    int vehicleImageId, {
    required int vehicleId,
    required int attachmentId,
    required bool isPrimary,
    required int displayOrder,
  }) async {
    try {
      await remote.updateVehicleImage(
        vehicleImageId,
        vehicleId: vehicleId,
        attachmentId: attachmentId,
        isPrimary: isPrimary,
        displayOrder: displayOrder,
      );

      return right(unit);
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }
}
