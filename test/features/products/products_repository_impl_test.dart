import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/core/errors/exceptions.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/features/products/data/datasources/products_remote_datasource.dart';
import 'package:small_task_au/features/products/data/models/product_model.dart';
import 'package:small_task_au/features/products/data/models/products_paginated_response_model.dart';
import 'package:small_task_au/features/products/data/repositories/products_repository_impl.dart';

class MockProductsRemoteDataSource implements ProductsRemoteDataSource {
  bool shouldThrowServerException = false;
  bool shouldThrowNetworkException = false;

  final tModel = const ProductModel(
    id: 1,
    title: 'Essence Mascara',
    description: 'Mascara description',
    price: 9.99,
    discountPercentage: 10.0,
    rating: 4.5,
    stock: 5,
    category: 'beauty',
    thumbnail: 'https://dummyjson.com/image.png',
    images: [],
  );

  @override
  Future<ProductsPaginatedResponseModel> getProducts({int limit = 10, int skip = 0}) async {
    if (shouldThrowServerException) {
      throw const ServerException('Server error', 500);
    }
    if (shouldThrowNetworkException) {
      throw const NetworkException('No internet connection');
    }
    return ProductsPaginatedResponseModel(
      products: [tModel],
      total: 1,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<ProductModel> getProductDetail(int id) async {
    if (shouldThrowServerException) {
      throw const ServerException('Product not found', 404);
    }
    return tModel;
  }
}

void main() {
  late MockProductsRemoteDataSource remoteDataSource;
  late ProductsRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockProductsRemoteDataSource();
    repository = ProductsRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  group('getProducts', () {
    test('returns ProductsPage on success', () async {
      final result = await repository.getProducts();

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.products.length, equals(1));
      expect(result.dataOrNull?.products.first.title, equals('Essence Mascara'));
      expect(result.dataOrNull?.hasReachedMax, isTrue);
    });

    test('returns ServerFailure on ServerException', () async {
      remoteDataSource.shouldThrowServerException = true;
      final result = await repository.getProducts();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });

    test('returns NetworkFailure on NetworkException', () async {
      remoteDataSource.shouldThrowNetworkException = true;
      final result = await repository.getProducts();

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<NetworkFailure>());
    });
  });

  group('getProductDetail', () {
    test('returns Product entity on success', () async {
      final result = await repository.getProductDetail(1);

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.id, equals(1));
    });

    test('returns ServerFailure when detail fetch fails', () async {
      remoteDataSource.shouldThrowServerException = true;
      final result = await repository.getProductDetail(99);

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull, isA<ServerFailure>());
    });
  });
}
