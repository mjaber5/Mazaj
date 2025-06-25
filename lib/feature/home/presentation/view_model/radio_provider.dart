import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/core/services/api_srvices.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  RadioStation? _currentStation;
  bool _isPlaying = false;
  List<RadioStation> _favorites = [];
  List<RadioStation> _recentlyPlayed = [];

  RadioStation? get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  List<RadioStation> get favorites => _favorites;
  List<RadioStation> get recentlyPlayed => _recentlyPlayed;

  RadioProvider() {
    _loadFavorites();
    _loadRecentlyPlayed();
  }

  Future<void> playStation(RadioStation station) async {
    try {
      if (_currentStation?.id != station.id) {
        await _audioPlayer.stop();
        await _audioPlayer.setAudioSource(
          AudioSource.uri(Uri.parse(station.streamUrl)),
        );
        await _audioPlayer.play();
        _currentStation = station;
        _isPlaying = true;
        _addToRecentlyPlayed(station);
        notifyListeners();
      } else {
        await togglePlayPause();
      }
    } catch (e) {
      debugPrint('Error playing station: $e');
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.play();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling play/pause: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentStation = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  Future<List<RadioStation>> fetchRadios({
    String? country,
    String? genres,
    String? search,
    bool featured = false,
    String? id,
    String? groupBy,
  }) async {
    try {
      return await _apiService.fetchRadios(
        country: country,
        genres: genres,
        search: search,
        featured: featured,
        id: id,
        groupBy: groupBy,
      );
    } catch (e) {
      debugPrint('Error fetching radios: $e');
      return [];
    }
  }

  void toggleFavorite(RadioStation station) {
    if (_favorites.any((fav) => fav.id == station.id)) {
      _favorites.removeWhere((fav) => fav.id == station.id);
    } else {
      _favorites.add(station);
    }
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(RadioStation station) {
    return _favorites.any((fav) => fav.id == station.id);
  }

  void _addToRecentlyPlayed(RadioStation station) {
    _recentlyPlayed.removeWhere((s) => s.id == station.id);
    _recentlyPlayed.insert(0, station);
    if (_recentlyPlayed.length > 10) _recentlyPlayed.removeLast();
    _saveRecentlyPlayed();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? favoritesJson = prefs.getString('favorites');
    if (favoritesJson != null) {
      final List<dynamic> favoritesList = jsonDecode(favoritesJson);
      _favorites =
          favoritesList.map((json) => RadioStation.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = jsonEncode(
      _favorites.map((fav) => fav.toJson()).toList(),
    );
    await prefs.setString('favorites', favoritesJson);
  }

  Future<void> _loadRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recently_played');
    if (recentJson != null) {
      final List<dynamic> recentList = jsonDecode(recentJson);
      _recentlyPlayed =
          recentList.map((json) => RadioStation.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final recentJson = jsonEncode(
      _recentlyPlayed.map((s) => s.toJson()).toList(),
    );
    await prefs.setString('recently_played', recentJson);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
