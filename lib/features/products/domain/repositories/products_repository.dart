import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';
import 'package:small_task_au/features/products/domain/entities/products_page.dart';

abstract class ProductsRepository {
  Future<Result<ProductsPage>> getProducts({
    int limit = 10,
    int skip = 0,
  });

  Future<Result<Product>> getProductDetail(int id);
}
