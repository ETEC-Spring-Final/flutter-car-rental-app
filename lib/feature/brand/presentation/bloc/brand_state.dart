part of 'brand_bloc.dart';

sealed class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object> get props => [];
}

class BrandInitial extends BrandState {}

class BrandsLoading extends BrandState {}

class BrandsLoaded extends BrandState {
  final List<Brand> brands;
  final int currentPage;
  final int totalPages;
  final bool hasReachedMax;
  final bool isLoadingMore;

  const BrandsLoaded({
    required this.brands,
    required this.currentPage,
    required this.totalPages,
    required this.hasReachedMax,
    this.isLoadingMore = false,
  });

  BrandsLoaded copyWith({
    List<Brand>? brands,
    int? currentPage,
    int? totalPages,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return BrandsLoaded(
      brands: brands ?? this.brands,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object> get props => [
    brands,
    currentPage,
    totalPages,
    hasReachedMax,
    isLoadingMore,
  ];
}

class BrandsError extends BrandState {
  final String message;
  const BrandsError(this.message);

  @override
  List<Object> get props => [message];
}
