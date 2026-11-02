import 'package:equatable/equatable.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class FetchProductsEvent extends ProductListEvent {
  const FetchProductsEvent();
}

class RefreshProductsEvent extends ProductListEvent {
  const RefreshProductsEvent();
}

class LoadMoreProductsEvent extends ProductListEvent {
  const LoadMoreProductsEvent();
}
