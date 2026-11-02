import 'package:small_task_au/core/errors/exceptions.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/products/data/datasources/products_remote_datasource.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';
import 'package:small_task_au/features/products/domain/entities/products_page.dart';
import 'package:small_task_au/features/products/domain/repositories/products_repository.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl({required ProductsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<ProductsPage>> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final responseModel = await _remoteDataSource.getProducts(
        limit: limit,
        skip: skip,
      );
      return Result.success(responseModel.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Product>> getProductDetail(int id) async {
    try {
      final model = await _remoteDataSource.getProductDetail(id);
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Result.failure(NetworkFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure('Failed to load product details: ${e.toString()}'));
    }
  }
}
