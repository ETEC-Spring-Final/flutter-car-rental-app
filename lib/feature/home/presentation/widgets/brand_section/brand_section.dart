import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_chips_shimmer.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_category.dart';

class BrandSection extends StatelessWidget {
  final int? selectedBrandId;
  final ValueChanged<Brand?> onBrandSelected;
  const BrandSection({
    super.key,
    required this.selectedBrandId,
    required this.onBrandSelected,
  });

  void _loadMoreBrand(BuildContext context) {
    context.read<BrandBloc>().add(const LoadMoreBrands());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandBloc, BrandState>(
      builder: (context, state) {
        if (state is BrandsLoading) {
          return const BrandChipsShimmer();
        }

        if (state is BrandsLoaded) {
          return BrandCategory(
            brands: state.brands,
            selectedBrandId: selectedBrandId,
            onBrandSelected: onBrandSelected,
            isLoadMore: state.isLoadingMore,
            onLoadMore: () => _loadMoreBrand(context),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
