import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle_image.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/repository/vehicle_repository.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;

  List<Vehicle> _vehicles = const [];
  List<Brand> _brands = const [];

  // Tracks whether the vehicle list has finished loading. Brand fetches
  // may complete independently, but the home/explore empty states must
  // not be shown until the vehicle fetch has actually finished (otherwise
  // a fast brand response emits VehicleLoaded with an empty vehicle list
  // while /vehicles is still in flight).
  bool _vehiclesLoaded = false;

  VehicleBloc(this.repository) : super(VehicleInitial()) {
    on<GetVehicles>(_onGetVehicles);
    on<GetVehicleById>(_onGetVehicleById);
    on<CreateVehicleEvent>(_onCreateVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
  }

  Future<void> _onGetVehicles(
    GetVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.getVehicles();

    result.fold((failure) => emit(VehicleError(failure.message)), (vehicles) {
      _vehicles = vehicles;
      _vehiclesLoaded = true;
      emit(VehicleLoaded(_vehicles));
    });
  }

  Future<void> _onGetVehicleById(
    GetVehicleById event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.getVehicleById(event.id);

    result.fold((failure) => emit(VehicleError(failure.message)), (vehicle) {
      _vehicles = [vehicle];
      emit(VehicleLoaded(_vehicles));
    });
  }

  Future<void> _onCreateVehicle(
    CreateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.createVehicle(event.vehicle);

    if (result.isLeft()) {
      emit(VehicleError(result.getLeft().toNullable()!.message));
      return;
    }

    final created = result.getRight().toNullable()!;
    final edits = event.imageEdits;

    if (edits != null && edits.newImages.isNotEmpty) {
      final upload = await repository.uploadVehicleImages(
        created.id,
        edits.newImages,
      );

      if (upload.isLeft()) {
        emit(VehicleError(upload.getLeft().toNullable()!.message));
        return;
      }

      final links = upload.getRight().toNullable()!;
      final primaryIndex = edits.primaryNewImageIndex;
      final primaryLink = primaryIndex != null && links.length > primaryIndex
          ? links[primaryIndex]
          : (links.isNotEmpty ? links.first : null);

      if (primaryLink != null) {
        final primary = await repository.updateVehicleImage(
          primaryLink.id,
          vehicleId: created.id,
          attachmentId: primaryLink.attachmentId,
          isPrimary: true,
          displayOrder: primaryLink.displayOrder,
        );

        if (primary.isLeft()) {
          emit(VehicleError(primary.getLeft().toNullable()!.message));
          return;
        }
      }
    }

    emit(const VehicleSuccess('Vehicle created successfully.'));
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.updateVehicle(event.vehicle);

    if (result.isLeft()) {
      emit(VehicleError(result.getLeft().toNullable()!.message));
      return;
    }

    final updated = result.getRight().toNullable()!;
    final edits = event.imageEdits;

    if (edits != null && !edits.isEmpty) {
      for (final id in edits.removeImageIds) {
        final removed = await repository.deleteVehicleImage(id);

        if (removed.isLeft()) {
          emit(VehicleError(removed.getLeft().toNullable()!.message));
          return;
        }
      }

      List<VehicleImage> links = const [];
      if (edits.newImages.isNotEmpty) {
        final upload = await repository.uploadVehicleImages(
          updated.id,
          edits.newImages,
        );

        if (upload.isLeft()) {
          emit(VehicleError(upload.getLeft().toNullable()!.message));
          return;
        }
        links = upload.getRight().toNullable()!;
      }

      if (edits.primaryNewImageIndex != null && links.isNotEmpty) {
        final index = edits.primaryNewImageIndex!;
        final link = links.length > index ? links[index] : links.first;

        final primary = await repository.updateVehicleImage(
          link.id,
          vehicleId: updated.id,
          attachmentId: link.attachmentId,
          isPrimary: true,
          displayOrder: link.displayOrder,
        );

        if (primary.isLeft()) {
          emit(VehicleError(primary.getLeft().toNullable()!.message));
          return;
        }
      } else if (edits.primaryImageId != null) {
        VehicleImage? target;
        for (final image in event.vehicle.images) {
          if (image.id == edits.primaryImageId) {
            target = image;
            break;
          }
        }

        if (target != null) {
          final primary = await repository.updateVehicleImage(
            target.id,
            vehicleId: updated.id,
            attachmentId: target.attachmentId,
            isPrimary: true,
            displayOrder: target.displayOrder,
          );

          if (primary.isLeft()) {
            emit(VehicleError(primary.getLeft().toNullable()!.message));
            return;
          }
        }
      }
    }

    emit(const VehicleSuccess('Vehicle updated successfully.'));
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicleEvent event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.deleteVehicle(event.id);

    result.fold(
      (failure) => emit(VehicleError(failure.message)),
      (_) => emit(const VehicleSuccess('Vehicle deleted successfully.')),
    );
  }
}
