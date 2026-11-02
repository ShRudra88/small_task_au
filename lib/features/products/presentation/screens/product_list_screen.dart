import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_event.dart';
import 'package:small_task_au/features/auth/presentation/bloc/auth_state.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_bloc.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_event.dart';
import 'package:small_task_au/features/products/presentation/bloc/product_list_state.dart';
import 'package:small_task_au/features/products/presentation/screens/product_detail_screen.dart';
import 'package:small_task_au/features/products/presentation/widgets/product_card.dart';
import 'package:small_task_au/features/products/presentation/widgets/product_shimmer.dart';
import 'package:small_task_au/features/products/presentation/widgets/state_widgets.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductListBloc>().add(const FetchProductsEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductListBloc>().add(const LoadMoreProductsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: const Size(80, 36),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Discover Products'),
                  Text(
                    'Hello, ${state.user.firstName} 👋',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }
            return const Text('Discover Products');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          if (state is ProductListLoading || state is ProductListInitial) {
            return const ProductShimmerList();
          }

          if (state is ProductListError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ProductListBloc>().add(const FetchProductsEvent());
              },
            );
          }

          if (state is ProductListEmpty) {
            return CustomEmptyWidget(
              onRefresh: () {
                context.read<ProductListBloc>().add(const FetchProductsEvent());
              },
            );
          }

          if (state is ProductListLoaded) {
            final products = state.products;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ProductListBloc>().add(const RefreshProductsEvent());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: products.length + 1,
                itemBuilder: (context, index) {
                  if (index < products.length) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: product.id,
                              initialProduct: product,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // Pagination Footer
                  if (state.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (state.loadMoreError != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            'Failed to load more products',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              context
                                  .read<ProductListBloc>()
                                  .add(const LoadMoreProductsEvent());
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry Loading More'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.hasReachedMax) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: Text(
                          'You\'ve reached the end of the list (${state.total} products)',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
