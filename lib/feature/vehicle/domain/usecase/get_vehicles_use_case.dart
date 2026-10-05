import 'package:fpdart/fpdart.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/repository/vehicle_repository.dart';

class GetVehiclesUseCase {
  final VehicleRepository repository;

  const GetVehiclesUseCase(this.repository);

  Future<Either<Failure, PageResponse<Vehicle>>> call({
    int page = 0,
    int size = 10,
    int? brandId,
    String? type,
    String? transmission,
    String? fuelType,
    double? minPrice,
    double? maxPrice,
    int? seats,
  }) {
    return repository.getVehicles(
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
  }

  // Future<Either<Failure, List<Vehicle>>> call() {
  //   return repository.getVehicles();
  // }
}
