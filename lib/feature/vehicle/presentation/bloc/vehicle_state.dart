part of 'vehicle_bloc.dart';

sealed class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

// ============================================================
// INITIAL
// ============================================================

class VehicleInitial extends VehicleState {}

// ============================================================
// LOADING
// ============================================================

class VehicleLoading extends VehicleState {}

// ============================================================
// LOADED
// ============================================================

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  // Pagination information
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;

  // True when loading the next page.
  //
  // This is different from VehicleLoading:
  //
  // VehicleLoading
  //     -> first page is loading
  //
  // VehicleLoaded(isLoadingMore: true)
  //     -> existing vehicles remain visible
  //        while the next page loads
  final bool isLoadingMore;

  const VehicleLoaded(
    this.vehicles, {
    this.currentPage = 0,
    this.totalPages = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  VehicleLoaded copyWith({
    List<Vehicle>? vehicles,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return VehicleLoaded(
      vehicles ?? this.vehicles,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    vehicles,
    currentPage,
    totalPages,
    hasReachedMax,
    isLoadingMore,
  ];
}

// ============================================================
// ERROR
// ============================================================

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============================================================
// SUCCESS
// ============================================================

class VehicleSuccess extends VehicleState {
  final String message;

  const VehicleSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
