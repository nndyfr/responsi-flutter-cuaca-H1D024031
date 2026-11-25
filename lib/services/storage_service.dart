import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class StorageService {
  static const _favKey = 'favorites';
  static const _lastKey = 'last_location';

  Future<List<LocationModel>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_favKey) ?? [];
    return raw.map((e) => LocationModel.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveFavorites(List<LocationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _favKey, list.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<LocationModel?> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastKey);
    if (raw == null) return null;
    return LocationModel.fromJson(jsonDecode(raw));
  }

  Future<void> saveLastLocation(LocationModel loc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastKey, jsonEncode(loc.toJson()));
  }
}