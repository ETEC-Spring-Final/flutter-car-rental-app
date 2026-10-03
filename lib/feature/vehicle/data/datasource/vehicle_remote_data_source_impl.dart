import 'dart:io';

import 'package:dio/dio.dart';
import 'package:vehicle_rental_system/core/constants/api_constants.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/datasource/vehicle_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_image_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/data/model/vehicle_model.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/booked_date.dart';

class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final Dio dio;

  VehicleRemoteDataSourceImpl(this.dio);

  @override
  Future<List<VehicleModel>> getVehicles() async {
    // Spring Boot returns a raw JSON list (not wrapped in { data: ... }).
    final response = await dio.get(ApiConstants.vehicles);

    final data = response.data as List;

    final vehicles = data
        .map((json) => VehicleModel.fromJson(json as Map<String, dynamic>))
        .toList();

    for (final vehicle in vehicles) {
      final images = await _fetchImages(vehicle.id);
      if (images.isNotEmpty) {
        vehicle.images
          ..clear()
          ..addAll(images);
      }
    }

    return vehicles;
  }

  @override
  Future<VehicleModel> getVehicleById(int id) async {
    final response = await dio.get(ApiConstants.vehicleById(id));

    final vehicle = VehicleModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    final images = await _fetchImages(id);
    if (images.isNotEmpty) {
      vehicle.images
        ..clear()
        ..addAll(images);
    }

    return vehicle;
  }

  @override
  Future<List<BookedDate>> getVehicleBookedDates(int vehicleId) async {
    final response = await dio.get(ApiConstants.vehicleBookedDates(vehicleId));

    final data = response.data as List;

    return data
        .map((json) => BookedDate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    final response = await dio.post(
      ApiConstants.vehicles,
      data: vehicle.toCreateRequest(),
    );

    final created = VehicleModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    await _attachImages(created);

    return created;
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    final response = await dio.put(
      ApiConstants.updateVehicle(vehicle.id),
      data: vehicle.toUpdateRequest(),
    );

    final updated = VehicleModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    await _attachImages(updated);

    return updated;
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await dio.delete(ApiConstants.deleteVehicle(id));
  }

  @override
  Future<List<VehicleImageModel>> uploadVehicleImages(
    int vehicleId,
    List<File> images,
  ) async {
    final created = <VehicleImageModel>[];

    for (final image in images) {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
        'documentType': 'VEHICLE_IMAGE',
      });

      final uploadResponse = await dio.post(
        ApiConstants.attachmentsUpload,
        data: formData,
      );
      final uploadData = uploadResponse.data as Map<String, dynamic>;
      final attachmentId = (uploadData['id'] as num?)?.toInt() ?? 0;

      final linkResponse = await dio.post(
        ApiConstants.vehicleImages,
        data: {
          'vehicleId': vehicleId,
          'attachmentId': attachmentId,
          'isPrimary': false,
          'displayOrder': 0,
        },
      );

      created.add(
        VehicleImageModel.fromJson(linkResponse.data as Map<String, dynamic>),
      );
    }

    return created;
  }

  @override
  Future<void> deleteVehicleImage(int vehicleImageId) async {
    await dio.delete(ApiConstants.deleteVehicleImage(vehicleImageId));
  }

  @override
  Future<void> updateVehicleImage(
    int vehicleImageId, {
    required int vehicleId,
    required int attachmentId,
    required bool isPrimary,
    required int displayOrder,
  }) async {
    await dio.put(
      ApiConstants.updateVehicleImage(vehicleImageId),
      data: {
        'vehicleId': vehicleId,
        'attachmentId': attachmentId,
        'isPrimary': isPrimary,
        'displayOrder': displayOrder,
      },
    );
  }

  Future<void> _attachImages(VehicleModel vehicle) async {
    final images = await _fetchImages(vehicle.id);
    if (images.isNotEmpty) {
      vehicle.images
        ..clear()
        ..addAll(images);
    }
  }

  /// Fetches `GET /vehicle-images/{vehicleId}` and maps the attachments.
  Future<List<VehicleImageModel>> _fetchImages(int vehicleId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.vehicleImages}/$vehicleId',
      );

      final data = response.data as List;

      return data.map((json) {
        final map = json as Map<String, dynamic>;
        final attachment = map['attachment'] as Map<String, dynamic>?;

        return VehicleImageModel(
          id: map['id'] ?? 0,
          vehicleId: (map['vehicleId'] as num?)?.toInt() ?? 0,
          attachmentId: attachment?['id'] ?? 0,
          fileUrl: attachment?['fileUrl'] ?? '',
          isPrimary: attachment?['isPrimary'] ?? false,
          displayOrder: attachment?['displayOrder'] ?? 0,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }
}
