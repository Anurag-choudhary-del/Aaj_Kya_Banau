import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'planner_screen.dart';
import 'recipes_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<KitchenStore>();
    final cartCount = store.cart.length;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(),
          RecipesScreen(),
          PlannerScreen(),
          CartScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.kitchen_outlined),
            selectedIcon: const Icon(Icons.kitchen),
            label: store.t('Pantry'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: store.t('Recipes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: store.t('Planner'),
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.saffron,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              backgroundColor: AppColors.saffron,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag),
            ),
            label: store.t('Cart'),
          ),
        ],
      ),
    );
  }
}
