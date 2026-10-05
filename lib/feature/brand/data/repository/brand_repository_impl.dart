import 'package:fpdart/src/either.dart';
import 'package:vehicle_rental_system/core/errors/failure.dart';
import 'package:vehicle_rental_system/feature/brand/data/datasource/brand_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/brand/data/mapper/brand_mapper.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/domain/repository/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final BrandRemoteDataSource remote;
  BrandRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, PageResponse<Brand>>> getBrands({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await remote.getBrands(page: page, size: size);
      return Right(
        PageResponse<Brand>(
          content: response.content.map(BrandMapper.toEntity).toList(),
          page: response.page,
          size: response.size,
          totalElements: response.totalElements,
          totalPages: response.totalPages,
          first: response.first,
          last: response.last,
        ),
      );
    } catch (e) {
      return left(ServiceFailure(e.toString()));
    }
  }
}
