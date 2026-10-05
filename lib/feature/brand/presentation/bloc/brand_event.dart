part of 'brand_bloc.dart';

sealed class BrandEvent extends Equatable {
  const BrandEvent();

  @override
  List<Object> get props => [];
}

class GetBrands extends BrandEvent {
  final bool refresh;

  const GetBrands({this.refresh = false});
}

class LoadMoreBrands extends BrandEvent {
  const LoadMoreBrands();
}
