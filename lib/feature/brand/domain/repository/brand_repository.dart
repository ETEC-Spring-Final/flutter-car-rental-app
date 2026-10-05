import 'package:fpdart/fpdart.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';

abstract class BrandRepository {
  Future<Either<Failure, PageResponse<Brand>>> getBrands({
    int page = 0,
    int size = 10,
  });
}
