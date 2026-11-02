import 'package:equatable/equatable.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';

abstract class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {}

class ProductListLoaded extends ProductListState {
  final List<Product> products;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? loadMoreError;
  final int total;

  const ProductListLoaded({
    required this.products,
    required this.hasReachedMax,
    this.isLoadingMore = false,
    this.loadMoreError,
    required this.total,
  });

  ProductListLoaded copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? loadMoreError,
    int? total,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        products,
        hasReachedMax,
        isLoadingMore,
        loadMoreError,
        total,
      ];
}

class ProductListEmpty extends ProductListState {}

class ProductListError extends ProductListState {
  final String message;

  const ProductListError(this.message);

  @override
  List<Object?> get props => [message];
}
