import '../../data/model/device_register_request.dart';
import '../repository/device_repository.dart';

class RegisterDeviceUseCase {
  final DeviceRepository repository;

  RegisterDeviceUseCase({required this.repository});

  Future<void> call(DeviceRegisterRequest request) async {
    await repository.registerDevice(request);
  }
}
