// audio_player_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/main.dart';
import 'package:provider/provider.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  BuildContext? _context;

  AudioPlayerCubit() : super(const AudioPlayerState()) {
    _init();
  }

  void _init() {
    emit(
      const AudioPlayerState(
        currentRadio: null,
        isPlaying: false,
        isLoading: false,
        error: null,
      ),
    );
    _audioPlayer.playerStateStream.listen((state) {
      debugPrint(
        'AudioPlayerCubit: Emitting state - playing=${state.playing}, processing=${state.processingState}',
      );
      emit(
        this.state.copyWith(
          isPlaying: state.playing,
          isLoading:
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering,
        ),
      );
    });
  }

  AudioPlayer get audioPlayer => _audioPlayer;
  BuildContext get context => _context!;

  Future<void> playRadio(RadioItem radio, BuildContext context) async {
    if (!context.mounted) return;
    _context = context;
    try {
      debugPrint('AudioPlayerCubit: Playing radio ${radio.id}');
      if (state.currentRadio?.id == radio.id && state.isPlaying) {
        await pauseRadio(context);
        return;
      }

      emit(state.copyWith(isLoading: true, currentRadio: radio));
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
      if (_context?.mounted ?? false) {
        final notificationManager = Provider.of<NotificationManager>(
          _context!,
          listen: false,
        );
        await notificationManager.showPlayingNotification(
          radio.name,
          radio.genres,
          radio.id,
          radio.logo,
        );
        final radioStation = RadioStation(
          id: radio.id,
          name: radio.name,
          logo: radio.logo,
          genres: radio.genres,
          streamUrl: radio.streamUrl,
          country: radio.country,
          featured: radio.featured,
          color: radio.color,
        );
        Provider.of<RadioProvider>(
          _context!,
          listen: false,
        ).addRecentlyPlayed(radioStation);
        Provider.of<RadioProvider>(
          _context!,
          listen: false,
        ).setLastPlayedTime(radio.id);
      }
      debugPrint('AudioPlayerCubit: Radio ${radio.id} playing');
      emit(
        state.copyWith(
          currentRadio: radio,
          isPlaying: true,
          isLoading: false,
          error: null,
        ),
      );
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error playing radio ${radio.id}: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error playing ${radio.name}',
          currentRadio: radio,
        ),
      );
    }
  }

  Future<void> pauseRadio(BuildContext context) async {
    if (!context.mounted) return;
    _context = context;
    await _audioPlayer.pause();
    if (_context?.mounted ?? false) {
      final notificationManager = Provider.of<NotificationManager>(
        _context!,
        listen: false,
      );
      await notificationManager.updateNotification(
        state.currentRadio!.name,
        state.currentRadio!.genres,
        state.currentRadio!.id,
        false,
      );
      debugPrint('AudioPlayerCubit: Radio ${state.currentRadio!.id} paused');
      emit(state.copyWith(isPlaying: false, isLoading: false));
    }
  }

  Future<void> resumeRadio(BuildContext context) async {
    if (!context.mounted) return;
    _context = context;
    if (state.currentRadio == null) return;

    try {
      debugPrint('AudioPlayerCubit: Resuming radio ${state.currentRadio!.id}');
      emit(state.copyWith(isLoading: true));
      await _audioPlayer.play();
      if (_context?.mounted ?? false) {
        final notificationManager = Provider.of<NotificationManager>(
          _context!,
          listen: false,
        );
        await notificationManager.updateNotification(
          state.currentRadio!.name,
          state.currentRadio!.genres,
          state.currentRadio!.id,
          true,
        );
      }
      debugPrint('AudioPlayerCubit: Radio ${state.currentRadio!.id} resumed');
      emit(state.copyWith(isPlaying: true, isLoading: false));
    } catch (e) {
      debugPrint(
        'AudioPlayerCubit: Error resuming radio ${state.currentRadio!.id}: $e',
      );
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error resuming ${state.currentRadio!.name}',
        ),
      );
    }
  }

  Future<void> stopRadio(BuildContext context) async {
    if (!context.mounted) return;
    _context = context;
    await _audioPlayer.stop();
    if (_context?.mounted ?? false) {
      final notificationManager = Provider.of<NotificationManager>(
        _context!,
        listen: false,
      );
      await notificationManager.cancelNotification();
      debugPrint('AudioPlayerCubit: Radio stopped');
      emit(
        state.copyWith(
          currentRadio: null,
          isPlaying: false,
          isLoading: false,
          error: null,
        ),
      );
    }
  }
}
