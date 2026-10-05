import 'package:fpdart/fpdart.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/domain/repository/brand_repository.dart';

class GetBrandUseCase {
  final BrandRepository repository;

  GetBrandUseCase(this.repository);

  Future<Either<Failure, PageResponse<Brand>>> call({
    int page = 0,
    int size = 10,
  }) {
    return repository.getBrands(page: page, size: size);
  }
}
