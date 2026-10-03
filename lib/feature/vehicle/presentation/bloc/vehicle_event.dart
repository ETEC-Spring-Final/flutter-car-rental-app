part of 'vehicle_bloc.dart';

sealed class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// GET VEHICLES
// ============================================================

class GetVehicles extends VehicleEvent {
  final bool refresh;

  // Explore filters
  final int? brandId;
  final String? type;
  final String? transmission;
  final String? fuelType;
  final double? minPrice;
  final double? maxPrice;
  final int? seats;

  const GetVehicles({
    this.refresh = false,
    this.brandId,
    this.type,
    this.transmission,
    this.fuelType,
    this.minPrice,
    this.maxPrice,
    this.seats,
  });

  @override
  List<Object?> get props => [
    refresh,
    brandId,
    type,
    transmission,
    fuelType,
    minPrice,
    maxPrice,
    seats,
  ];
}

// ============================================================
// GET VEHICLE BY ID
// ============================================================

class GetVehicleById extends VehicleEvent {
  final int id;

  const GetVehicleById(this.id);

  @override
  List<Object?> get props => [id];
}

// ============================================================
// CREATE VEHICLE
// ============================================================

class CreateVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;
  final VehicleImageEdits? imageEdits;

  const CreateVehicleEvent({required this.vehicle, this.imageEdits});

  @override
  List<Object?> get props => [vehicle, imageEdits];
}

// ============================================================
// UPDATE VEHICLE
// ============================================================

class UpdateVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;
  final VehicleImageEdits? imageEdits;

  const UpdateVehicleEvent({required this.vehicle, this.imageEdits});

  @override
  List<Object?> get props => [vehicle, imageEdits];
}

// ============================================================
// DELETE VEHICLE
// ============================================================

class DeleteVehicleEvent extends VehicleEvent {
  final int id;

  const DeleteVehicleEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// ============================================================
// VEHICLE IMAGE EDITS
// ============================================================

class VehicleImageEdits extends Equatable {
  final List<File> newImages;
  final List<int> removeImageIds;

  // Index of a newly uploaded image that should become primary.
  final int? primaryNewImageIndex;

  // ID of an existing image that should become primary.
  final int? primaryImageId;

  const VehicleImageEdits({
    this.newImages = const [],
    this.removeImageIds = const [],
    this.primaryNewImageIndex,
    this.primaryImageId,
  });

  bool get isEmpty =>
      newImages.isEmpty &&
      removeImageIds.isEmpty &&
      primaryNewImageIndex == null &&
      primaryImageId == null;

  @override
  List<Object?> get props => [
    newImages,
    removeImageIds,
    primaryNewImageIndex,
    primaryImageId,
  ];
}
