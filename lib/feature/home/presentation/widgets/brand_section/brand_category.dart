import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_loading.dart';
import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_category_item.dart';

class BrandCategory extends StatefulWidget {
  final List<Brand> brands;
  final int? selectedBrandId;
  final ValueChanged<Brand?> onBrandSelected;
  final bool isLoadMore;
  final VoidCallback onLoadMore;

  const BrandCategory({
    super.key,
    required this.brands,
    required this.selectedBrandId,
    required this.onBrandSelected,
    required this.isLoadMore,
    required this.onLoadMore,
  });

  @override
  State<BrandCategory> createState() => _BrandCategoryState();
}

class _BrandCategoryState extends State<BrandCategory> {
  final ScrollController _scrollController = ScrollController();
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;

    // Load more when 200px from end

    if (position.pixels >= position.maxScrollExtent - 100) {
      widget.onLoadMore();
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.brands.length + 1 + (widget.isLoadMore ? 1 : 0);
    return SizedBox(
      height: 55.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.space12),
        itemCount: itemCount,
        separatorBuilder: (_, __) {
          return SizedBox(width: AppDimensions.space16);
        },
        itemBuilder: (context, index) {
          // ======================================
          // ALL
          // ======================================

          if (index == 0) {
            return BrandCategoryItem(
              title: 'All',
              image: '',
              isSelected: widget.selectedBrandId == null,
              onTap: () {
                widget.onBrandSelected(null);

                log('Filter: All');
              },
            );
          }

          // Loading indicator
          if (index == widget.brands.length + 1) {
            return widget.isLoadMore
                ? const Center(child: AppLoading())
                : const SizedBox.shrink();
          }

          // ======================================
          // BRAND
          // ======================================

          final brand = widget.brands[index - 1];

          return BrandCategoryItem(
            title: brand.name,
            image: brand.imageUrl,
            isSelected: widget.selectedBrandId == brand.id,
            onTap: () {
              widget.onBrandSelected(brand);

              log(
                'Filter: ${brand.name}'
                '(id: ${brand.id})',
              );
            },
          );
        },
      ),
    );
  }
}
