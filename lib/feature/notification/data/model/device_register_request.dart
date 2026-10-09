class DeviceRegisterRequest {
  final String fcmToken;
  final String deviceType;

  const DeviceRegisterRequest({
    required this.fcmToken,
    required this.deviceType,
  });

  Map<String, dynamic> toJson() {
    return {'token': fcmToken, 'deviceType': deviceType};
  }
}
