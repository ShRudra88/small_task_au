import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_detail_bloc.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_detail_event.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_detail_state.dart';

import 'product_list_bloc_test.dart';

void main() {
  late MockProductsRepository repository;
  late GetProductDetailUseCase getProductDetailUseCase;
  late ProductDetailBloc productDetailBloc;

  setUp(() {
    repository = MockProductsRepository();
    getProductDetailUseCase = GetProductDetailUseCase(repository);
    productDetailBloc = ProductDetailBloc(getProductDetailUseCase: getProductDetailUseCase);
  });

  tearDown(() {
    productDetailBloc.close();
  });

  test('initial state is ProductDetailInitial', () {
    expect(productDetailBloc.state, isA<ProductDetailInitial>());
  });

  test('emits [ProductDetailLoading, ProductDetailLoaded] on successful fetch', () async {
    final expectedStates = [
      isA<ProductDetailLoading>(),
      isA<ProductDetailLoaded>(),
    ];

    expectLater(productDetailBloc.stream, emitsInOrder(expectedStates));
    productDetailBloc.add(const FetchProductDetailEvent(1));
  });

  test('emits [ProductDetailLoading, ProductDetailError] when fetch fails', () async {
    repository.shouldReturnError = true;

    final expectedStates = [
      isA<ProductDetailLoading>(),
      isA<ProductDetailError>(),
    ];

    expectLater(productDetailBloc.stream, emitsInOrder(expectedStates));
    productDetailBloc.add(const FetchProductDetailEvent(99));
  });
}
