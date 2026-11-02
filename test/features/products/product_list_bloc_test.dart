import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/core/errors/failures.dart';
import 'package:small_task_au/core/utils/result.dart';
import 'package:small_task_au/features/products/domain/entities/product.dart';
import 'package:small_task_au/features/products/domain/entities/products_page.dart';
import 'package:small_task_au/features/products/domain/repositories/products_repository.dart';
import 'package:small_task_au/features/products/domain/usecases/get_products_usecase.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_event.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_state.dart';

class MockProductsRepository implements ProductsRepository {
  bool shouldReturnError = false;
  bool shouldReturnEmpty = false;

  final tProduct = const Product(
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
  Future<Result<ProductsPage>> getProducts({int limit = 10, int skip = 0}) async {
    if (shouldReturnError) {
      return const Result.failure(ServerFailure('Server error'));
    }
    if (shouldReturnEmpty) {
      return Result.success(
        ProductsPage(
          products: const [],
          total: 0,
          skip: 0,
          limit: limit,
          hasReachedMax: true,
        ),
      );
    }
    return Result.success(
      ProductsPage(
        products: [tProduct],
        total: 1,
        skip: skip,
        limit: limit,
        hasReachedMax: true,
      ),
    );
  }

  @override
  Future<Result<Product>> getProductDetail(int id) async {
    if (shouldReturnError) {
      return const Result.failure(ServerFailure('Product not found'));
    }
    return Result.success(tProduct);
  }
}

void main() {
  late MockProductsRepository repository;
  late GetProductsUseCase getProductsUseCase;
  late ProductListBloc productListBloc;

  setUp(() {
    repository = MockProductsRepository();
    getProductsUseCase = GetProductsUseCase(repository);
    productListBloc = ProductListBloc(getProductsUseCase: getProductsUseCase);
  });

  tearDown(() {
    productListBloc.close();
  });

  test('initial state is ProductListInitial', () {
    expect(productListBloc.state, isA<ProductListInitial>());
  });

  test('emits [ProductListLoading, ProductListLoaded] on successful fetch', () async {
    final expectedStates = [
      isA<ProductListLoading>(),
      isA<ProductListLoaded>(),
    ];

    expectLater(productListBloc.stream, emitsInOrder(expectedStates));
    productListBloc.add(const FetchProductsEvent());
  });

  test('emits [ProductListLoading, ProductListEmpty] when products list is empty', () async {
    repository.shouldReturnEmpty = true;

    final expectedStates = [
      isA<ProductListLoading>(),
      isA<ProductListEmpty>(),
    ];

    expectLater(productListBloc.stream, emitsInOrder(expectedStates));
    productListBloc.add(const FetchProductsEvent());
  });

  test('emits [ProductListLoading, ProductListError] when fetch fails', () async {
    repository.shouldReturnError = true;

    final expectedStates = [
      isA<ProductListLoading>(),
      isA<ProductListError>(),
    ];

    expectLater(productListBloc.stream, emitsInOrder(expectedStates));
    productListBloc.add(const FetchProductsEvent());
  });
}
