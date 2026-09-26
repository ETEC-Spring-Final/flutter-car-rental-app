part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  /// Vehicles of the pages loaded so far, already narrowed to [selectedBrand].
  final List<Vehicle> vehicles;

  /// Brands of the pages loaded so far.
  final List<Brand> brands;

  /// Name of the active brand chip, or null for "All".
  final String? selectedBrand;

  final bool hasMoreVehicles;
  final bool hasMoreBrands;

  /// True while page zero of the vehicle list is in flight, either on the
  /// first load or after the brand filter changed.
  final bool isLoadingVehicles;

  /// True while a "load more" page is in flight, so the section can show a
  /// spinner instead of the section being empty.
  final bool isLoadingMoreVehicles;
  final bool isLoadingMoreBrands;

  /// True from the moment a pull to refresh is accepted until its pages have
  /// arrived. Unlike [isLoadingVehicles] the content stays on screen, so the
  /// screen can hold the pull to refresh indicator open for the whole request.
  final bool isRefreshing;

  /// Totals across every page, used for the "no cars" check and the counter.
  final int totalVehicles;
  final int totalBrands;

  /// Number of active reservation windows per vehicle id, for the vehicles
  /// loaded so far. See `HomeBloc` for why this is fetched per vehicle.
  final Map<int, int> reservationCounts;

  const HomeLoaded({
    required this.vehicles,
    required this.brands,
    this.selectedBrand,
    required this.hasMoreVehicles,
    required this.hasMoreBrands,
    this.isLoadingVehicles = false,
    this.isLoadingMoreVehicles = false,
    this.isLoadingMoreBrands = false,
    this.isRefreshing = false,
    required this.totalVehicles,
    required this.totalBrands,
    this.reservationCounts = const {},
  });

  /// True when the API has no vehicle for the active brand at all, which is
  /// different from "the loaded pages happen to be empty".
  bool get hasNoVehicles => !isLoadingVehicles && totalVehicles == 0;

  /// [vehicles] ordered by how often they have been reserved, which is what
  /// the popular section shows.
  ///
  /// Derived from the loaded pages rather than paged on its own, so popular
  /// and recommended always cover the same vehicles. A vehicle whose count has
  /// not arrived yet counts as zero, and ties keep the API order, so the
  /// section is already correct before the counts land and only refines after.
  List<Vehicle> get popularVehicles {
    if (reservationCounts.isEmpty) return vehicles;

    final ranked = [...vehicles.indexed]..sort((a, b) {
      final byReservations = _reservationsFor(
        b.$2.id,
      ).compareTo(_reservationsFor(a.$2.id));

      return byReservations != 0 ? byReservations : a.$1.compareTo(b.$1);
    });

    return [for (final (_, vehicle) in ranked) vehicle];
  }

  int _reservationsFor(int vehicleId) => reservationCounts[vehicleId] ?? 0;

  HomeLoaded copyWith({
    List<Vehicle>? vehicles,
    List<Brand>? brands,
    String? selectedBrand,
    bool clearSelectedBrand = false,
    bool? hasMoreVehicles,
    bool? hasMoreBrands,
    bool? isLoadingVehicles,
    bool? isLoadingMoreVehicles,
    bool? isLoadingMoreBrands,
    bool? isRefreshing,
    int? totalVehicles,
    int? totalBrands,
    Map<int, int>? reservationCounts,
  }) {
    return HomeLoaded(
      vehicles: vehicles ?? this.vehicles,
      brands: brands ?? this.brands,
      selectedBrand: clearSelectedBrand
          ? null
          : selectedBrand ?? this.selectedBrand,
      hasMoreVehicles: hasMoreVehicles ?? this.hasMoreVehicles,
      hasMoreBrands: hasMoreBrands ?? this.hasMoreBrands,
      isLoadingVehicles: isLoadingVehicles ?? this.isLoadingVehicles,
      isLoadingMoreVehicles: isLoadingMoreVehicles ?? this.isLoadingMoreVehicles,
      isLoadingMoreBrands: isLoadingMoreBrands ?? this.isLoadingMoreBrands,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      totalVehicles: totalVehicles ?? this.totalVehicles,
      totalBrands: totalBrands ?? this.totalBrands,
      reservationCounts: reservationCounts ?? this.reservationCounts,
    );
  }

  @override
  List<Object?> get props => [
    vehicles,
    brands,
    selectedBrand,
    hasMoreVehicles,
    hasMoreBrands,
    isLoadingVehicles,
    isLoadingMoreVehicles,
    isLoadingMoreBrands,
    isRefreshing,
    totalVehicles,
    totalBrands,
    reservationCounts,
  ];
}
