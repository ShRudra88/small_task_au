import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:small_task_au/core/network/api_client.dart';
import 'package:small_task_au/core/storage/secure_storage_service.dart';
import 'package:small_task_au/core/theme/app_theme.dart';
import 'package:small_task_au/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:small_task_au/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:small_task_au/features/auth/domain/repositories/auth_repository.dart';
import 'package:small_task_au/features/auth/domain/usecases/check_auth_status_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/login_usecase.dart';
import 'package:small_task_au/features/auth/domain/usecases/logout_usecase.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_event.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_state.dart';
import 'package:small_task_au/features/auth/presentation/screens/login_screen.dart';
import 'package:small_task_au/features/products/data/datasources/products_remote_datasource.dart';
import 'package:small_task_au/features/products/data/repositories/products_repository_impl.dart';
import 'package:small_task_au/features/products/domain/repositories/products_repository.dart';
import 'package:small_task_au/features/products/domain/usecases/get_product_detail_usecase.dart';
import 'package:small_task_au/features/products/domain/usecases/get_products_usecase.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:small_task_au/features/products/presentation/screens/product_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Core Services
  final secureStorage = SecureStorageServiceImpl();
  final apiClient = ApiClient(secureStorage: secureStorage);

  // Data Sources
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final productsRemoteDataSource = ProductsRemoteDataSourceImpl(apiClient: apiClient);

  // Repositories
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorage: secureStorage,
  );
  final productsRepository = ProductsRepositoryImpl(
    remoteDataSource: productsRemoteDataSource,
  );

  // Use Cases
  final loginUseCase = LoginUseCase(authRepository);
  final checkAuthStatusUseCase = CheckAuthStatusUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getProductsUseCase = GetProductsUseCase(productsRepository);
  final getProductDetailUseCase = GetProductDetailUseCase(productsRepository);

  runApp(
    MyApp(
      authRepository: authRepository,
      productsRepository: productsRepository,
      loginUseCase: loginUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
      logoutUseCase: logoutUseCase,
      getProductsUseCase: getProductsUseCase,
      getProductDetailUseCase: getProductDetailUseCase,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final ProductsRepository productsRepository;
  final LoginUseCase loginUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LogoutUseCase logoutUseCase;
  final GetProductsUseCase getProductsUseCase;
  final GetProductDetailUseCase getProductDetailUseCase;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.productsRepository,
    required this.loginUseCase,
    required this.checkAuthStatusUseCase,
    required this.logoutUseCase,
    required this.getProductsUseCase,
    required this.getProductDetailUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ProductsRepository>.value(value: productsRepository),
        RepositoryProvider<GetProductsUseCase>.value(value: getProductsUseCase),
        RepositoryProvider<GetProductDetailUseCase>.value(value: getProductDetailUseCase),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              loginUseCase: loginUseCase,
              checkAuthStatusUseCase: checkAuthStatusUseCase,
              logoutUseCase: logoutUseCase,
            )..add(CheckAuthStatusRequested()),
          ),
          BlocProvider<ProductListBloc>(
            create: (context) => ProductListBloc(
              getProductsUseCase: getProductsUseCase,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'DummyJSON Store',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const ProductListScreen();
        }

        if (state is Unauthenticated || state is AuthFailureState) {
          return const LoginScreen();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
