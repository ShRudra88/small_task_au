import 'package:equatable/equatable.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';

class ProductsPage extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;
  final bool hasReachedMax;

  const ProductsPage({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [products, total, skip, limit, hasReachedMax];
}
