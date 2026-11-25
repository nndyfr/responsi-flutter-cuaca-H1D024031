import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import 'view_state.dart';

class SearchViewModel extends ChangeNotifier {
  final WeatherService _service;
  final StorageService _storage;

  SearchViewModel(this._service, this._storage);

  List<LocationModel> results = [];
  List<LocationModel> favorites = [];
  List<LocationModel> history = [];
  ViewState state = ViewState.idle;
  String errorMessage = '';
  String _lastQuery = '';

  Future<void> loadFavorites() async {
    favorites = await _storage.loadFavorites();
    notifyListeners();
  }

  Future<void> loadHistory() async {
    history = await _storage.loadHistory();
    notifyListeners();
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return;
    _lastQuery = trimmed;
    state = ViewState.loading;
    notifyListeners();
    try {
      final fetchedResults = await _service.searchCity(trimmed);
      if (_lastQuery != trimmed) return;
      results = fetchedResults
          .where((loc) => loc.country.toLowerCase() == 'indonesia')
          .toList();
      state = results.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      if (_lastQuery != trimmed) return;
      errorMessage = 'Gagal mencari kota. Periksa koneksi internet.';
      state = ViewState.error;
    }
    notifyListeners();
  }

  void clear() {
    _lastQuery = '';
    results = [];
    state = ViewState.idle;
    errorMessage = '';
    notifyListeners();
  }

  Future<void> addToHistory(LocationModel loc) async {
    history.removeWhere((e) => e == loc);
    history.insert(0, loc);
    if (history.length > 10) {
      history.removeLast();
    }
    await _storage.saveHistory(history);
    notifyListeners();
  }

  Future<void> removeFromHistory(LocationModel loc) async {
    history.remove(loc);
    await _storage.saveHistory(history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    history.clear();
    await _storage.saveHistory(history);
    notifyListeners();
  }

  bool isFavorite(LocationModel loc) => favorites.contains(loc);

  Future<void> toggleFavorite(LocationModel loc) async {
    if (isFavorite(loc)) {
      favorites.remove(loc);
    } else {
      favorites.add(loc);
    }
    await _storage.saveFavorites(favorites);
    notifyListeners();
  }
}
