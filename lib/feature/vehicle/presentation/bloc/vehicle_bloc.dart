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

  // Tracks whether the first vehicle request has completed.
  bool _vehiclesLoaded = false;

  // Pagination
  static const int _pageSize = 10;
  int _currentPage = 0;
  bool _hasReachedMax = false;

  // Current Explore filters
  int? _brandId;
  String? _type;
  String? _transmission;
  String? _fuelType;
  double? _minPrice;
  double? _maxPrice;
  int? _seats;

  VehicleBloc(this.repository) : super(VehicleInitial()) {
    on<GetVehicles>(_onGetVehicles);
    on<GetVehicleById>(_onGetVehicleById);
    on<CreateVehicleEvent>(_onCreateVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
  }

  // ============================================================
  // GET VEHICLES
  // ============================================================

  Future<void> _onGetVehicles(
    GetVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    // ------------------------------------------------------------
    // REFRESH / FIRST LOAD
    // ------------------------------------------------------------

    if (event.refresh || state is VehicleInitial) {
      _currentPage = 0;
      _hasReachedMax = false;

      // Save the filters from the event.
      _brandId = event.brandId;
      _type = event.type;
      _transmission = event.transmission;
      _fuelType = event.fuelType;
      _minPrice = event.minPrice;
      _maxPrice = event.maxPrice;
      _seats = event.seats;

      emit(VehicleLoading());

      final result = await repository.getVehicles(
        page: _currentPage,
        size: _pageSize,
        brandId: _brandId,
        type: _type,
        transmission: _transmission,
        fuelType: _fuelType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        seats: _seats,
      );

      result.fold(
        (failure) {
          _vehiclesLoaded = true;
          emit(VehicleError(failure.message));
        },
        (response) {
          _vehicles = response.content;
          _currentPage = response.page;
          _hasReachedMax = response.last;
          _vehiclesLoaded = true;

          emit(
            VehicleLoaded(
              _vehicles,
              currentPage: _currentPage,
              totalPages: response.totalPages,
              hasReachedMax: _hasReachedMax,
              isLoadingMore: false,
            ),
          );
        },
      );

      return;
    }

    // ------------------------------------------------------------
    // LOAD NEXT PAGE
    // ------------------------------------------------------------

    if (state is VehicleLoaded) {
      final currentState = state as VehicleLoaded;

      // Don't request another page if one is already loading.
      if (currentState.isLoadingMore) {
        return;
      }

      // Don't request another page when we reached the last page.
      if (_hasReachedMax) {
        return;
      }

      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = _currentPage + 1;

      final result = await repository.getVehicles(
        page: nextPage,
        size: _pageSize,
        brandId: _brandId,
        type: _type,
        transmission: _transmission,
        fuelType: _fuelType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        seats: _seats,
      );

      result.fold(
        (failure) {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (response) {
          // Add the next page to the existing vehicles.
          _vehicles = [..._vehicles, ...response.content];

          _currentPage = response.page;
          _hasReachedMax = response.last;

          emit(
            VehicleLoaded(
              _vehicles,
              currentPage: _currentPage,
              totalPages: response.totalPages,
              hasReachedMax: _hasReachedMax,
              isLoadingMore: false,
            ),
          );
        },
      );
    }
  }

  // ============================================================
  // GET VEHICLE BY ID
  // ============================================================

  Future<void> _onGetVehicleById(
    GetVehicleById event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());

    final result = await repository.getVehicleById(event.id);

    result.fold((failure) => emit(VehicleError(failure.message)), (vehicle) {
      _vehicles = [vehicle];

      emit(
        VehicleLoaded(
          _vehicles,
          currentPage: 0,
          totalPages: 1,
          hasReachedMax: true,
          isLoadingMore: false,
        ),
      );
    });
  }

  // ============================================================
  // CREATE VEHICLE
  // ============================================================

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

  // ============================================================
  // UPDATE VEHICLE
  // ============================================================

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
      // ----------------------------------------------------------
      // DELETE OLD IMAGES
      // ----------------------------------------------------------

      for (final id in edits.removeImageIds) {
        final removed = await repository.deleteVehicleImage(id);

        if (removed.isLeft()) {
          emit(VehicleError(removed.getLeft().toNullable()!.message));
          return;
        }
      }

      // ----------------------------------------------------------
      // UPLOAD NEW IMAGES
      // ----------------------------------------------------------

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

      // ----------------------------------------------------------
      // SET NEW IMAGE AS PRIMARY
      // ----------------------------------------------------------

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
      }
      // ----------------------------------------------------------
      // SET EXISTING IMAGE AS PRIMARY
      // ----------------------------------------------------------
      else if (edits.primaryImageId != null) {
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

  // ============================================================
  // DELETE VEHICLE
  // ============================================================

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
