import 'package:dio/dio.dart';
import 'package:vehicle_rental_system/core/constants/api_constants.dart';
import 'package:vehicle_rental_system/feature/brand/data/datasource/brand_remote_data_source.dart';
import 'package:vehicle_rental_system/feature/brand/data/model/brand_model.dart';
import 'package:vehicle_rental_system/core/data/page_response.dart';

class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final Dio dio;

  BrandRemoteDataSourceImpl(this.dio);

  @override
  Future<PageResponse<BrandModel>> getBrands({
    int page = 0,
    int size = 10,
  }) async {
    final response = await dio.get(
      ApiConstants.brands,
      queryParameters: {'page': page, 'size': size},
    );

    // Spring Boot returns a Page object as JSON.
    final data = response.data as Map<String, dynamic>;

    // Only "content" is a List.
    final content = (data['content'] as List<dynamic>? ?? [])
        .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
        .toList();

    return PageResponse<BrandModel>(
      content: content,
      page: (data['number'] as num?)?.toInt() ?? 0,
      size: (data['size'] as num?)?.toInt() ?? size,
      totalElements: (data['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 0,
      first: data['first'] as bool? ?? false,
      last: data['last'] as bool? ?? false,
    );
  }
}
