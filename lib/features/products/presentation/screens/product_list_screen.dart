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
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Beauty',
    'Fragrances',
    'Furniture',
    'Groceries',
  ];

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              minimumSize: const Size(90, 40),
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
            final firstName = state is Authenticated ? state.user.firstName : 'Explorer';
            return Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Explore products',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            );
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
      body: Column(
        children: [
          // Horizontal Category Filter Pills
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    backgroundColor: Colors.white,
                    elevation: isSelected ? 2 : 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          // Main Product List Content
          Expanded(
            child: BlocBuilder<ProductListBloc, ProductListState>(
              builder: (context, state) {
                if (state is ProductListLoading || state is ProductListInitial) {
                  return const ProductShimmerList();
                }

                if (state is ProductListError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context
                          .read<ProductListBloc>()
                          .add(const FetchProductsEvent());
                    },
                  );
                }

                if (state is ProductListEmpty) {
                  return CustomEmptyWidget(
                    onRefresh: () {
                      context
                          .read<ProductListBloc>()
                          .add(const FetchProductsEvent());
                    },
                  );
                }

                if (state is ProductListLoaded) {
                  final filteredProducts = _selectedCategory == 'All'
                      ? state.products
                      : state.products
                          .where((p) =>
                              p.category.toLowerCase() ==
                              _selectedCategory.toLowerCase())
                          .toList();

                  if (filteredProducts.isEmpty && _selectedCategory != 'All') {
                    return CustomEmptyWidget(
                      title: 'No $_selectedCategory Products',
                      subtitle: 'Try selecting a different category or refresh.',
                      onRefresh: () {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: theme.colorScheme.primary,
                    onRefresh: () async {
                      context
                          .read<ProductListBloc>()
                          .add(const RefreshProductsEvent());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredProducts.length + 1,
                      itemBuilder: (context, index) {
                        if (index < filteredProducts.length) {
                          final product = filteredProducts[index];
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
          ),
        ],
      ),
    );
  }
}
