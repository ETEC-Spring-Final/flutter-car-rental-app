import '../../domain/repository/device_repository.dart';
import '../datasource/device_remote_data_source.dart';
import '../model/device_register_request.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;

  DeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> registerDevice(DeviceRegisterRequest request) async {
    await remoteDataSource.registerDevice(request);
  }
}
