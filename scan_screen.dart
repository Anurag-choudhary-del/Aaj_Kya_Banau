import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/pantry_item.dart';
import '../services/ingredient_recognition_service.dart';
import '../state/kitchen_store.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final Set<String> _selected = {};
  List<Map<String, String>> _detected = [];
  XFile? _image;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Home screen par Camera scan tap karte hi phone ka camera khul jaye.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _chooseImage(ImageSource.camera);
    });
  }

  Future<void> _chooseImage(ImageSource source) async {
    if (_loading) return;
    try {
      final image = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1600);
      if (image == null || !mounted) return;
      setState(() {
        _image = image;
        _detected = [];
        _selected.clear();
        _error = null;
        _loading = true;
      });
      final bytes = await image.readAsBytes();
      final result = await IngredientRecognitionService().recognize(
        base64Encode(bytes),
        image.mimeType ?? 'image/jpeg',
      );
      if (!mounted) return;
      setState(() {
        _detected = result;
        _selected.addAll(result.map((item) => item['name']!).where((name) => name.isNotEmpty));
        _loading = false;
        if (result.isEmpty) _error = 'Koi saaf ingredient nahi mila. Roshni mein paas se photo lekar dobara try karo.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _addSelected() {
    final store = context.read<KitchenStore>();
    for (final item in _detected) {
      final name = item['name'] ?? '';
      if (name.isEmpty || !_selected.contains(name)) continue;
      store.addPantryItem(PantryItem(
        id: 'photo-${DateTime.now().microsecondsSinceEpoch}-${name.hashCode}',
        name: name,
        emoji: item['emoji'] ?? '🥬',
      ));
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14110F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14110F),
        foregroundColor: Colors.white,
        title: const Text('Scan or upload photo'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(File(_image!.path), height: 250, fit: BoxFit.cover),
              )
            else
              Container(
                height: 210,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A241F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.document_scanner_outlined, color: Colors.white, size: 52),
                    SizedBox(height: 12),
                    Text('Camera se photo lo ya gallery se chuno', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: _loading ? null : () => _chooseImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Camera scan'),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: _loading ? null : () => _chooseImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Photo upload'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              )),
            ]),
            const SizedBox(height: 20),
            if (_loading) const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('AI photo mein ingredients pehchaan raha hai…', style: TextStyle(color: Colors.white70)),
              ]),
            )),
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14)),
                child: Text(_error!, style: const TextStyle(color: Colors.white)),
              ),
            if (_detected.isNotEmpty && !_loading) ...[
              const Text('Pehchaane gaye items — confirm karne se pehle check karo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _detected.map((item) {
                  final name = item['name']!;
                  return FilterChip(
                    selected: _selected.contains(name),
                    label: Text('${item['emoji'] ?? '🥬'} $name'),
                    onSelected: (value) => setState(() {
                      value ? _selected.add(name) : _selected.remove(name);
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _selected.isEmpty ? null : _addSelected,
                child: Text('Add ${_selected.length} selected item(s) to pantry'),
              ),
            ],
            const SizedBox(height: 12),
            const Text('Items tabhi pantry mein add honge jab tum select karke confirm karoge.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
