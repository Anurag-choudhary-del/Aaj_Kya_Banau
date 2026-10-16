import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/kitchen_catalog.dart';
import '../state/kitchen_store.dart';
import '../theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _line;
  bool _found = false;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _found = true);
    });
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finds = KitchenCatalog.scanFinds();

    return Scaffold(
      backgroundColor: const Color(0xFF14110F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan pantry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: AnimatedBuilder(
                  animation: _line,
                  builder: (context, _) {
                    return AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white24, width: 2),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF2A241F), Color(0xFF1A1613)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Text('🥬  🍅  🧅', style: TextStyle(fontSize: 42)),
                            ),
                            if (!_found)
                              Align(
                                alignment: Alignment(0, (_line.value * 2) - 1),
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 18),
                                  decoration: BoxDecoration(
                                    color: AppColors.saffron,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.saffron.withValues(alpha: 0.7),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_found)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.72),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Detected items',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          for (final item in finds)
                                            Chip(
                                              avatar: Text(item.emoji),
                                              label: Text(item.name),
                                              backgroundColor: Colors.white,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _found ? 'Looks tasty. Add these to your pantry?' : 'Hold steady… AI is reading labels',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: !_found
                      ? null
                      : () {
                          context.read<KitchenStore>().addScanFinds();
                          Navigator.pop(context, true);
                        },
                  child: Text(_found ? 'Add to pantry' : 'Scanning…'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
