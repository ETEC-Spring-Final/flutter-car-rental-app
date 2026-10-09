import 'package:dio/dio.dart';
import 'package:vehicle_rental_system/core/constants/api_constants.dart';
import 'package:vehicle_rental_system/feature/notification/data/datasource/device_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/notification/data/model/device_register_request.dart';

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;

  DeviceRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> registerDevice(DeviceRegisterRequest request) async {
    await dio.post(ApiConstants.device, data: request.toJson());
  }
}
