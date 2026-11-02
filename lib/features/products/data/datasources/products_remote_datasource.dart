import 'package:small_task_au/core/network/api_client.dart';
import 'package:small_task_au/features/products/data/models/product_model.dart';
import 'package:small_task_au/features/products/data/models/products_paginated_response_model.dart';

abstract class ProductsRemoteDataSource {
  Future<ProductsPaginatedResponseModel> getProducts({
    int limit = 10,
    int skip = 0,
  });

  Future<ProductModel> getProductDetail(int id);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient _apiClient;

  ProductsRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ProductsPaginatedResponseModel> getProducts({
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await _apiClient.get(
      '/products',
      queryParameters: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
    );
    return ProductsPaginatedResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> getProductDetail(int id) async {
    final response = await _apiClient.get('/products/$id');
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }
}
