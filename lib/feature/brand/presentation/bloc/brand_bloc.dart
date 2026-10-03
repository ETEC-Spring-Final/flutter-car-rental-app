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
  }
  // method handles the GetBrands event.
  Future<void> _onLoadBrands(GetBrands event, Emitter<BrandState> emit) async {
    if (event.refresh || state is BrandInitial) {
      // The UI can show a full-screen loading indicator.
      emit(BrandsLoading());
      // Call the UseCase to request the first page.
      final result = await getBrandUseCase(page: 0, size: pageSize);
      // Either<Failure, PageResponse<Brand>>
      //
      // result contain:
      // Left  -> something went wrong
      // Right -> request was successful
      result.fold(
        // REQUEST FAILED
        (failure) {
          // Send an error state to the UI.
          emit(BrandsError(failure.message));
        },
        // REQUEST SUCCESSFUL
        (response) {
          // response contains both:
          //
          // 1. Brand data
          // 2. Pagination information
          //
          // For example:
          //
          // content       -> [Toyota, BMW, Ford...]
          // page          -> 0
          // totalPages    -> 3
          // totalElements -> 25
          // last          -> false
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
      return;
    }
    if (state is BrandsLoaded) {
      // Convert the current state into BrandLoaded
      // so we can access its properties.
      final currentState = state as BrandsLoaded;
      // 3. PREVENT DUPLICATE REQUESTS
      // ==========================================================
      //
      // Don't request another page if:
      //
      // A. Another page is already loading
      //
      // OR
      //
      // B. We already reached the last page.
      if (currentState.isLoadingMore || currentState.hasReachedMax) {
        // Do nothing
        return;
      }
      // 4. TELL UI THAT NEXT PAGE IS LOADING
      //
      // We don't use BrandLoading here.
      //
      // Because BrandLoading might make the UI remove the existing brands
      // and show a full-screen loading indicator.
      //
      // Instead, we keep the existing brands and only tell the UI
      // that more data is loading.
      //
      // Example UI:
      //
      // Toyota
      // BMW
      // Ford
      // Lexus
      // MG
      // ----------
      // Loading...
      emit(currentState.copyWith(isLoadingMore: true));
      // 5. CALCULATE NEXT PAGE
      //
      // If currentPage = 0:
      //
      // nextPage = 0 + 1 = 1
      //
      // If currentPage = 1:
      //
      // nextPage = 1 + 1 = 2
      final nextPage = currentState.currentPage + 1;
      // 6. REQUEST NEXT PAGE FROM BACKEND
      //
      // Example:
      //
      // Current page = 0
      // Next page    = 1
      //
      // GET /brands?page=1&size=10
      final result = await getBrandUseCase(page: nextPage, size: pageSize);
      // 7. HANDLE RESULT
      result.fold(
        (failure) {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        // LOAD MORE SUCCESSFUL
        (response) {
          // Add the new brands to the existing brands.
          //
          // Example:
          //
          // Existing:
          // [Toyota, BMW, Ford]
          //
          // New page:
          // [Lexus, MG]
          //
          // Result:
          // [Toyota, BMW, Ford, Lexus, MG]
          final updatedBrands = [...currentState.brands, ...response.content];
          // Send the updated list to the UI.
          emit(
            BrandsLoaded(
              // Existing brands + new brands
              brands: updatedBrands,
              // Update current page.
              //
              // Example:
              // 0 -> 1
              // 1 -> 2
              currentPage: response.page,
              // Update total pages.
              totalPages: response.totalPages,
              // Backend tells us whether this is the last page.
              hasReachedMax: response.last,
              // Loading is finished.
              isLoadingMore: false,
            ),
          );
        },
      );
    }
  }
}
