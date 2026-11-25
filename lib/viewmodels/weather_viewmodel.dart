import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';
import 'view_state.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _service;
  final StorageService _storage;

  WeatherViewModel(this._service, this._storage);

  LocationModel? location;
  WeatherData? weather;
  ViewState state = ViewState.idle;
  String errorMessage = '';

  /// Dipanggil saat app dibuka: muat kota terakhir dari local storage.
  Future<void> init() async {
    final last = await _storage.loadLastLocation();
    if (last != null) {
      await selectLocation(last);
    }
  }

  Future<void> selectLocation(LocationModel loc) async {
    location = loc;
    await _storage.saveLastLocation(loc);
    await loadWeather();
  }

  Future<void> loadWeather() async {
    final loc = location;
    if (loc == null) return;
    state = ViewState.loading;
    notifyListeners();
    try {
      weather = await _service.getWeather(loc.latitude, loc.longitude);
      state = ViewState.success;
    } catch (e) {
      errorMessage = 'Gagal memuat cuaca. Periksa koneksi internet.';
      state = ViewState.error;
    }
    notifyListeners();
  }
}