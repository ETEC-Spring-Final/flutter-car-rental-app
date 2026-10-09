import '../../data/model/device_register_request.dart';

abstract class DeviceRepository {
  Future<void> registerDevice(DeviceRegisterRequest request);
}
