part of 'vehicle_bloc.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class GetVehicles extends VehicleEvent {
  const GetVehicles();
}

class GetVehicleById extends VehicleEvent {
  final int id;

  const GetVehicleById(this.id);

  @override
  List<Object?> get props => [id];
}

/// Describes the image changes the user made in the vehicle form.
class VehicleImageEdits {
  /// Files to upload and attach to the vehicle (additions + replacements).
  final List<File> newImages;

  /// Existing vehicle-image ids to delete (including replaced ones).
  final Set<int> removeImageIds;

  /// Existing vehicle-image id that must become the primary/cover photo.
  final int? primaryImageId;

  /// Index into [newImages] whose uploaded link must become primary.
  final int? primaryNewImageIndex;

  const VehicleImageEdits({
    this.newImages = const [],
    this.removeImageIds = const {},
    this.primaryImageId,
    this.primaryNewImageIndex,
  });

  bool get isEmpty =>
      newImages.isEmpty &&
      removeImageIds.isEmpty &&
      primaryImageId == null &&
      primaryNewImageIndex == null;

  @override
  bool operator ==(Object other) =>
      other is VehicleImageEdits &&
      identical(newImages, other.newImages) &&
      identical(removeImageIds, other.removeImageIds) &&
      primaryImageId == other.primaryImageId &&
      primaryNewImageIndex == other.primaryNewImageIndex;

  @override
  int get hashCode => Object.hash(
    newImages,
    removeImageIds,
    primaryImageId,
    primaryNewImageIndex,
  );
}

class CreateVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;
  final VehicleImageEdits? imageEdits;

  const CreateVehicleEvent(this.vehicle, [this.imageEdits]);

  @override
  List<Object?> get props => [vehicle, imageEdits];
}

class UpdateVehicleEvent extends VehicleEvent {
  final Vehicle vehicle;
  final VehicleImageEdits? imageEdits;

  const UpdateVehicleEvent(this.vehicle, [this.imageEdits]);

  @override
  List<Object?> get props => [vehicle, imageEdits];
}

class DeleteVehicleEvent extends VehicleEvent {
  final int id;

  const DeleteVehicleEvent(this.id);

  @override
  List<Object?> get props => [id];
}
