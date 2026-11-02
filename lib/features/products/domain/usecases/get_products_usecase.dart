import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/products/domain/entities/products_page.dart';
import 'package:small_task_au/features/products/domain/repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;

  GetProductsUseCase(this._repository);

  Future<Result<ProductsPage>> call({
    int limit = 10,
    int skip = 0,
  }) {
    return _repository.getProducts(limit: limit, skip: skip);
  }
}
