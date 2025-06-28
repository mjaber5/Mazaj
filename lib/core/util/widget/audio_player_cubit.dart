import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:mazaj_radio/main.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

part 'audio_player_state.dart';

class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final MyAudioHandler _audioHandler;

  AudioPlayerCubit(this._audioHandler) : super(const AudioPlayerState()) {
    _init();
  }

  void _init() {
    _audioHandler.playbackState.listen((playbackState) {
      debugPrint(
        'AudioPlayerCubit: Emitting state - playing=${playbackState.playing}, processing=${playbackState.processingState}',
      );
      emit(
        this.state.copyWith(
          isPlaying: playbackState.playing,
          isLoading:
              playbackState.processingState == AudioProcessingState.loading ||
              playbackState.processingState == AudioProcessingState.buffering,
        ),
      );
    });
  }

  Future<void> playRadio(RadioItem radio, BuildContext context) async {
    if (!context.mounted) return;
    try {
      debugPrint('AudioPlayerCubit: Playing radio ${radio.id}');
      if (state.currentRadio?.id == radio.id && state.isPlaying) {
        await pauseRadio(context);
        return;
      }

      emit(state.copyWith(isLoading: true, currentRadio: radio));
      await _audioHandler.playRadio(radio);
      if (!context.mounted) return;
      try {
        final notificationManager = Provider.of<NotificationManager>(
          context,
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
          context,
          listen: false,
        ).addRecentlyPlayed(radioStation);
        Provider.of<RadioProvider>(
          context,
          listen: false,
        ).setLastPlayedTime(radio.id);
      } catch (e) {
        debugPrint(
          'AudioPlayerCubit: Provider error for radio ${radio.id}: $e',
        );
        // Continue playback even if provider fails
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
    await _audioHandler.pause();
    if (!context.mounted) return;
    try {
      final notificationManager = Provider.of<NotificationManager>(
        context,
        listen: false,
      );
      await notificationManager.updateNotification(
        state.currentRadio!.name,
        state.currentRadio!.genres,
        state.currentRadio!.id,
        false,
      );
    } catch (e) {
      debugPrint('AudioPlayerCubit: Provider error on pause: $e');
    }
    debugPrint('AudioPlayerCubit: Radio ${state.currentRadio!.id} paused');
    emit(state.copyWith(isPlaying: false, isLoading: false));
  }

  Future<void> resumeRadio(BuildContext context) async {
    if (!context.mounted || state.currentRadio == null) return;
    try {
      debugPrint('AudioPlayerCubit: Resuming radio ${state.currentRadio!.id}');
      emit(state.copyWith(isLoading: true));
      await _audioHandler.play();
      if (!context.mounted) return;
      try {
        final notificationManager = Provider.of<NotificationManager>(
          context,
          listen: false,
        );
        await notificationManager.updateNotification(
          state.currentRadio!.name,
          state.currentRadio!.genres,
          state.currentRadio!.id,
          true,
        );
      } catch (e) {
        debugPrint('AudioPlayerCubit: Provider error on resume: $e');
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

  // In AudioPlayerCubit
  bool _isStopping = false;
  Future<void> stopRadio(BuildContext context) async {
    if (!context.mounted || _isStopping) return;
    _isStopping = true;
    debugPrint('AudioPlayerCubit: Stopping radio');
    await _audioHandler.stop();
    if (!context.mounted) {
      _isStopping = false;
      return;
    }
    try {
      final notificationManager = Provider.of<NotificationManager>(
        context,
        listen: false,
      );
      await notificationManager.cancelNotification();
    } catch (e) {
      debugPrint('AudioPlayerCubit: Provider error on stop: $e');
    }
    debugPrint('AudioPlayerCubit: Radio stopped, emitting state');
    emit(
      state.copyWith(
        currentRadio: null,
        isPlaying: false,
        isLoading: false,
        error: null,
      ),
    );
    _isStopping = false;
  }

  @override
  Future<void> close() {
    _audioHandler.stop();
    return super.close();
  }
}
