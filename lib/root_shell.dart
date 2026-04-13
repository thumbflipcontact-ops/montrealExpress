import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [HomePage(), CartPage(), ChatPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.store_outlined, color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.store, color: colorScheme.primary),
            label: 'Achat',
          ),
          NavigationDestination(
            icon: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                return Badge(
                  isLabelVisible: state.items.isNotEmpty,
                  label: Text('${state.items.length}'),
                  backgroundColor: colorScheme.error,
                  child: Icon(Icons.shopping_bag_outlined, color: colorScheme.onSurfaceVariant),
                );
              },
            ),
            selectedIcon: BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                return Badge(
                  isLabelVisible: state.items.isNotEmpty,
                  label: Text('${state.items.length}'),
                  backgroundColor: colorScheme.error,
                  child: Icon(Icons.shopping_bag, color: colorScheme.primary),
                );
              },
            ),
            label: 'Panier',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline, color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.chat_bubble, color: colorScheme.primary),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.person, color: colorScheme.primary),
            label: 'Profile',
          ),
        ],
        indicatorColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        shadowColor: colorScheme.shadow,
        elevation: 0,
      ),
    );
  }
}
