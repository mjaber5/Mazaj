import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mazaj_radio/core/services/api_srvices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';

class RadioProvider with ChangeNotifier {
  List<RadioStation> _recentlyPlayed = [];
  List<RadioStation> _favorites = [];
  List<RadioStation> _allStations = [];
  static const String _recentKey = 'recently_played_radios';
  static const String _favoriteKey = 'favorite_radios';
  final ApiService _apiService = ApiService();

  List<RadioStation> get recentlyPlayed => _recentlyPlayed;
  List<RadioStation> get favorites => _favorites;
  List<RadioStation> get allStations => _allStations;

  RadioProvider() {
    _loadRecentlyPlayed();
    _loadFavorites();
    _loadAllStations();
  }

  Future<void> _loadRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final String? radiosJson = prefs.getString(_recentKey);
    if (radiosJson != null) {
      final List<dynamic> radiosList = jsonDecode(radiosJson);
      _recentlyPlayed =
          radiosList.map((json) => RadioStation.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString(_favoriteKey);
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favorites =
          favoritesList.map((json) => RadioStation.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _loadAllStations() async {
    try {
      _allStations = await _apiService.fetchRadios();
      notifyListeners();
    } catch (e) {
      debugPrint('RadioProvider: Error loading all stations: $e');
    }
  }

  Future<void> addRecentlyPlayed(RadioStation radio) async {
    final prefs = await SharedPreferences.getInstance();
    _recentlyPlayed.removeWhere((r) => r.id == radio.id);
    _recentlyPlayed.insert(0, radio);
    if (_recentlyPlayed.length > 4) {
      _recentlyPlayed = _recentlyPlayed.take(4).toList();
    }
    final radiosJson = jsonEncode(
      _recentlyPlayed.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_recentKey, radiosJson);
    notifyListeners();
  }

  Future<void> addFavorite(RadioStation radio) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.removeWhere((r) => r.id == radio.id);
    _favorites.add(radio);
    final favoritesJson = jsonEncode(
      _favorites.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_favoriteKey, favoritesJson);
    notifyListeners();
  }

  Future<void> removeFavorite(RadioStation radio) async {
    final prefs = await SharedPreferences.getInstance();
    _favorites.removeWhere((r) => r.id == radio.id);
    final favoritesJson = jsonEncode(
      _favorites.map((r) => r.toJson()).toList(),
    );
    await prefs.setString(_favoriteKey, favoritesJson);
    notifyListeners();
  }

  bool isFavorite(RadioStation radio) {
    return _favorites.any((r) => r.id == radio.id);
  }

  Future<void> toggleFavorite(RadioStation radio) async {
    if (isFavorite(radio)) {
      await removeFavorite(radio);
    } else {
      await addFavorite(radio);
    }
  }

  Future<String> getLastPlayedTime(String radioId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('last_played_$radioId') ?? 'Unknown';
  }

  Future<void> setLastPlayedTime(String radioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_played_$radioId',
      DateTime.now().toIso8601String(),
    );
    notifyListeners();
  }

  RadioStation? getNextStation(String currentRadioId) {
    final stations =
        _recentlyPlayed.isNotEmpty ? _recentlyPlayed : _allStations;
    final currentIndex = stations.indexWhere((r) => r.id == currentRadioId);
    return currentIndex != -1 && currentIndex < stations.length - 1
        ? stations[currentIndex + 1]
        : stations.firstOrNull;
  }

  RadioStation? getPreviousStation(String currentRadioId) {
    final stations =
        _recentlyPlayed.isNotEmpty ? _recentlyPlayed : _allStations;
    final currentIndex = stations.indexWhere((r) => r.id == currentRadioId);
    return currentIndex > 0 ? stations[currentIndex - 1] : stations.lastOrNull;
  }
}
