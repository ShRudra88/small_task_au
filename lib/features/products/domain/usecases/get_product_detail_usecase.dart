import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';
import 'package:small_task_au/features/products/domain/repositories/products_repository.dart';

class GetProductDetailUseCase {
  final ProductsRepository _repository;

  GetProductDetailUseCase(this._repository);

  Future<Result<Product>> call(int id) {
    return _repository.getProductDetail(id);
  }
}
