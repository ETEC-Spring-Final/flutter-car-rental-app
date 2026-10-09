import '../model/device_register_request.dart';

abstract class DeviceRemoteDataSource {
  Future<void> registerDevice(DeviceRegisterRequest request);
}
