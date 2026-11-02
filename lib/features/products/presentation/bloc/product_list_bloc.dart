import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:small_task_au/features/products/domain/usecases/get_products_usecase.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_event.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetProductsUseCase _getProductsUseCase;
  static const int _pageLimit = 10;

  ProductListBloc({required GetProductsUseCase getProductsUseCase})
      : _getProductsUseCase = getProductsUseCase,
        super(ProductListInitial()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<RefreshProductsEvent>(_onRefreshProducts);
    on<LoadMoreProductsEvent>(_onLoadMoreProducts);
  }

  Future<void> _onFetchProducts(
    FetchProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    emit(ProductListLoading());
    final result = await _getProductsUseCase(limit: _pageLimit, skip: 0);

    result.fold(
      (failure) => emit(ProductListError(failure.message)),
      (page) {
        if (page.products.isEmpty) {
          emit(ProductListEmpty());
        } else {
          emit(
            ProductListLoaded(
              products: page.products,
              hasReachedMax: page.hasReachedMax,
              total: page.total,
            ),
          );
        }
      },
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    final result = await _getProductsUseCase(limit: _pageLimit, skip: 0);

    result.fold(
      (failure) {
        if (state is! ProductListLoaded) {
          emit(ProductListError(failure.message));
        }
      },
      (page) {
        if (page.products.isEmpty) {
          emit(ProductListEmpty());
        } else {
          emit(
            ProductListLoaded(
              products: page.products,
              hasReachedMax: page.hasReachedMax,
              total: page.total,
            ),
          );
        }
      },
    );
  }

  Future<void> _onLoadMoreProducts(
    LoadMoreProductsEvent event,
    Emitter<ProductListState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductListLoaded ||
        currentState.hasReachedMax ||
        currentState.isLoadingMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true, loadMoreError: null));

    final result = await _getProductsUseCase(
      limit: _pageLimit,
      skip: currentState.products.length,
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(
          isLoadingMore: false,
          loadMoreError: failure.message,
        ));
      },
      (page) {
        final updatedProducts = List.of(currentState.products)..addAll(page.products);
        final bool hasReachedMax = page.hasReachedMax || updatedProducts.length >= page.total;

        emit(
          ProductListLoaded(
            products: updatedProducts,
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
            total: page.total,
          ),
        );
      },
    );
  }
}
