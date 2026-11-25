import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<SearchViewModel>();
      vm.loadHistory();
      vm.clear();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    if (text.trim().isEmpty) {
      context.read<SearchViewModel>().clear();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SearchViewModel>().search(text);
    });
  }

  void _select(LocationModel loc) {
    final vm = context.read<SearchViewModel>();
    vm.addToHistory(loc);
    context.read<WeatherViewModel>().selectLocation(loc);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField Pencarian dengan Live Search & Debounce
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: vm.search,
              decoration: InputDecoration(
                hintText: 'Masukkan nama kota (contoh: Jakarta)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade100, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Hapus',
                            onPressed: () {
                              _controller.clear();
                              context.read<SearchViewModel>().clear();
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Favorit (dari local storage)
            if (vm.favorites.isNotEmpty) ...[
              Text(
                'Kota Favorit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: vm.favorites
                    .map((f) => InputChip(
                          avatar: const Icon(Icons.star, size: 18, color: Colors.amber),
                          label: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          backgroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue.shade100),
                          ),
                          onPressed: () => _select(f),
                          onDeleted: () => vm.toggleFavorite(f),
                          deleteIcon: const Icon(Icons.close, size: 16, color: Colors.grey),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Judul Dinamis (Riwayat Pencarian vs Hasil Pencarian)
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final isEmptyInput = value.text.trim().isEmpty;
                if (isEmptyInput && vm.history.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Riwayat Pencarian',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                      ),
                      TextButton(
                        onPressed: vm.clearHistory,
                        child: const Text('Hapus semua', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  );
                } else {
                  return Text(
                    'Hasil Pencarian',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final isEmptyInput = value.text.trim().isEmpty;
                  if (isEmptyInput && vm.history.isNotEmpty) {
                    return ListView.builder(
                      itemCount: vm.history.length,
                      itemBuilder: (context, i) {
                        final loc = vm.history[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Icon(Icons.history, color: Colors.blue.shade400),
                            title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(loc.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              tooltip: 'Hapus dari riwayat',
                              onPressed: () => vm.removeFromHistory(loc),
                            ),
                            onTap: () => _select(loc),
                          ),
                        );
                      },
                    );
                  } else if (isEmptyInput && vm.history.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 56, color: Colors.blue.shade200),
                          const SizedBox(height: 12),
                          const Text(
                            'Ketik nama kota untuk mencari',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return _buildResults(vm, value.text);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(SearchViewModel vm, String currentText) {
    if (currentText.trim().length < 2) {
      return Center(
        child: Text(
          'Ketik minimal 2 huruf',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      );
    }

    switch (vm.state) {
      case ViewState.loading:
        return const Center(child: CircularProgressIndicator(color: Colors.blue));
      case ViewState.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('Kota tidak ditemukan', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
      case ViewState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(vm.errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => vm.search(_controller.text),
                style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        );
      case ViewState.success:
        return ListView.builder(
          itemCount: vm.results.length,
          itemBuilder: (context, i) {
            final loc = vm.results[i];
            final fav = vm.isFavorite(loc);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.location_on_outlined, color: Colors.blue.shade700),
                ),
                title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(loc.label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                trailing: IconButton(
                  icon: Icon(
                    fav ? Icons.star : Icons.star_border,
                    color: fav ? Colors.amber : Colors.grey,
                  ),
                  tooltip: 'Simpan ke favorit',
                  onPressed: () => vm.toggleFavorite(loc),
                ),
                onTap: () => _select(loc),
              ),
            );
          },
        );
      case ViewState.idle:
        return Center(
          child: Text(
            'Ketik minimal 2 huruf',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        );
    }
  }
}
