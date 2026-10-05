import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehicle_rental_system/core/widgets/brand_chips_shimmer.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_category.dart';

class BrandSection extends StatelessWidget {
  final selectedBrandIndex;
  final ValueChanged<int> onBrandSelected;
  const BrandSection({
    super.key,
    required this.selectedBrandIndex,
    required this.onBrandSelected,
  });

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
            selectedBrandIndex: selectedBrandIndex,
            onBrandSelected: onBrandSelected,
            isLoadMore: state.isLoadingMore,
            onLoadMore: () {
              context.read<BrandBloc>().add(const LoadMoreBrands());
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
