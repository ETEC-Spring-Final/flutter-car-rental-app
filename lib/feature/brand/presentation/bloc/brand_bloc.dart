import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/domain/usecase/get_brand_use_case.dart';

part 'brand_event.dart';
part 'brand_state.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final GetBrandUseCase getBrandUseCase;

  static const int pageSize = 10;

  BrandBloc(this.getBrandUseCase) : super(BrandInitial()) {
    on<GetBrands>(_onLoadBrands);
    on<LoadMoreBrands>(_onLoadMoreBrands);
  }
  // method handles the GetBrands event.
  Future<void> _onLoadBrands(GetBrands event, Emitter<BrandState> emit) async {
    emit(BrandsLoading());

    final result = await getBrandUseCase(page: 0, size: pageSize);

    result.fold(
      (failure) {
        emit(BrandsError(failure.message));
      },
      (response) {
        emit(
          BrandsLoaded(
            brands: response.content,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.last,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMoreBrands(
    LoadMoreBrands event,
    Emitter<BrandState> emit,
  ) async {
    if (state is! BrandsLoaded) return;

    final currentState = state as BrandsLoaded;

    if (currentState.isLoadingMore || currentState.hasReachedMax) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await getBrandUseCase(page: nextPage, size: pageSize);

    result.fold(
      (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        final updatedBrands = [...currentState.brands, ...response.content];

        emit(
          BrandsLoaded(
            brands: updatedBrands,
            currentPage: response.page,
            totalPages: response.totalPages,
            hasReachedMax: response.last,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}
