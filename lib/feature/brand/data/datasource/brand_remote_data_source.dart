import 'package:vehicle_rental_system/feature/brand/data/model/brand_model.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';

abstract class BrandRemoteDataSource {
  Future<PageResponse<BrandModel>> getBrands({int page = 0, int size = 10});
}
