import 'package:vehicle_rental_system/feature/brand/data/model/brand_model.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';

class BrandMapper {
  const BrandMapper._();

  static Brand toEntity(BrandModel model) =>
      Brand(id: model.id, name: model.name, imageUrl: model.imageUrl);

  static BrandModel toModel(Brand entity) =>
      BrandModel(id: entity.id, name: entity.name, imageUrl: entity.imageUrl);
}
