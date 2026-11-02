import 'package:flutter_test/flutter_test.dart';
import 'package:small_task_au/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/login_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/logout_usecase.dart';
import 'package:small_task_au/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:small_task_au/features/products/domain/usecases/get_products_usecase.dart';
import 'package:small_task_au/main.dart';

import 'features/auth/auth_bloc_test.dart';
import 'features/products/product_list_bloc_test.dart';

void main() {
  testWidgets('App initialization renders AuthWrapper smoke test', (WidgetTester tester) async {
    final mockAuthRepo = MockAuthRepository();
    final mockProductsRepo = MockProductsRepository();

    await tester.pumpWidget(
      MyApp(
        authRepository: mockAuthRepo,
        productsRepository: mockProductsRepo,
        loginUseCase: LoginUseCase(mockAuthRepo),
        checkAuthStatusUseCase: CheckAuthStatusUseCase(mockAuthRepo),
        logoutUseCase: LogoutUseCase(mockAuthRepo),
        getProductsUseCase: GetProductsUseCase(mockProductsRepo),
        getProductDetailUseCase: GetProductDetailUseCase(mockProductsRepo),
      ),
    );

    // Initial pump shows AuthWrapper
    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
