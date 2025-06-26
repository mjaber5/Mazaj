import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/main.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final NotificationManager _notificationManager = NotificationManager();

  AudioPlayerCubit() : super(const AudioPlayerState()) {
    _init();
  }

  void _init() {
    _audioPlayer.playerStateStream.listen((state) {
      emit(this.state.copyWith(isPlaying: state.playing));
    });
  }

  AudioPlayer get audioPlayer => _audioPlayer;

  Future<void> playRadio(RadioItem radio) async {
    try {
      if (state.currentRadio?.id == radio.id && state.isPlaying) {
        await _audioPlayer.pause();
        await _notificationManager.cancelNotification();
        emit(state.copyWith(isPlaying: false));
        return;
      }

      final mediaItem = MediaItem(
        id: radio.id,
        title: radio.name,
        artist: radio.genres,
        artUri: Uri.parse(radio.logo),
      );

      await _audioPlayer.setAudioSource(
        AudioSource.uri(Uri.parse(radio.streamUrl), tag: mediaItem),
      );
      await _audioPlayer.play();
      await _notificationManager.showPlayingNotification(
        radio.name,
        radio.genres,
      );
      emit(state.copyWith(currentRadio: radio, isPlaying: true, error: null));
    } catch (e) {
      debugPrint('Error playing radio: $e');
      emit(state.copyWith(error: 'Error playing ${radio.name}'));
    }
  }

  Future<void> pauseRadio() async {
    await _audioPlayer.pause();
    await _notificationManager.cancelNotification();
    emit(state.copyWith(isPlaying: false));
  }

  Future<void> stopRadio() async {
    await _audioPlayer.stop();
    await _notificationManager.cancelNotification();
    emit(state.copyWith(currentRadio: null, isPlaying: false, error: null));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
