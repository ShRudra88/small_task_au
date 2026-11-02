import 'package:small_task_au/features/products/data/models/product_model.dart';
import 'package:small_task_au/features/products/domain/entities/products_page.dart';

class ProductsPaginatedResponseModel {
  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsPaginatedResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory ProductsPaginatedResponseModel.fromJson(Map<String, dynamic> json) {
    final rawProducts = json['products'] as List<dynamic>? ?? [];
    final products = rawProducts
        .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return ProductsPaginatedResponseModel(
      products: products,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 10,
    );
  }

  ProductsPage toEntity() {
    final entityList = products.map((model) => model.toEntity()).toList();
    final bool hasReachedMax = (skip + products.length) >= total;

    return ProductsPage(
      products: entityList,
      total: total,
      skip: skip,
      limit: limit,
      hasReachedMax: hasReachedMax,
    );
  }
}
