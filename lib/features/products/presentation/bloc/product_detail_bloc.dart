import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:small_task_au/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_detail_event.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_detail_state.dart';

class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductDetailUseCase _getProductDetailUseCase;

  ProductDetailBloc({required GetProductDetailUseCase getProductDetailUseCase})
      : _getProductDetailUseCase = getProductDetailUseCase,
        super(ProductDetailInitial()) {
    on<FetchProductDetailEvent>(_onFetchProductDetail);
  }

  Future<void> _onFetchProductDetail(
    FetchProductDetailEvent event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());
    final result = await _getProductDetailUseCase(event.id);
    result.fold(
      (failure) => emit(ProductDetailError(failure.message)),
      (product) => emit(ProductDetailLoaded(product)),
    );
  }
}
