import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/main_shell.dart';
import 'state/kitchen_store.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AajKyaBanauApp());
}

class AajKyaBanauApp extends StatelessWidget {
  const AajKyaBanauApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => KitchenStore(),
      child: MaterialApp(
        title: 'Aaj Kya Banau',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const MainShell(),
      ),
    );
  }
}
