import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mazaj_radio/core/util/widget/my_audio_handler.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

part 'audio_player_state.dart';

/// Manages the state and logic for audio playback using the BLoC pattern.
class AudioPlayerCubit extends Cubit<AudioPlayerState> {
  final MyAudioHandler _audioHandler;

  AudioPlayerCubit(this._audioHandler) : super(const AudioPlayerState()) {
    _init();
  }

  /// Initializes the cubit by setting up listeners and observers.
  void _init() {
    _audioHandler.playbackState.listen((playbackState) {
      debugPrint(
        'AudioPlayerCubit: Emitting state - playing=${playbackState.playing}, processing=${playbackState.processingState}',
      );
      emit(
        state.copyWith(
          isPlaying: playbackState.playing,
          isLoading: playbackState.processingState == AudioProcessingState.loading ||
              playbackState.processingState == AudioProcessingState.buffering,
          position: playbackState.updatePosition,
          bufferedPosition: playbackState.bufferedPosition,
        ),
      );
    });

    // Sync state when app resumes from background
    WidgetsBinding.instance.addObserver(
      _AppLifecycleObserver(
        onResume: () {
          _syncState();
        },
      ),
    );
  }

  /// Syncs the cubit state with the audio handler's current state.
  void _syncState() {
    final playbackState = _audioHandler.playbackState.value;
    final mediaItem = _audioHandler.mediaItem.value;
    debugPrint(
      'AudioPlayerCubit: Syncing state - playing=${playbackState.playing}, mediaItem=${mediaItem?.title}',
    );
    emit(
      state.copyWith(
        isPlaying: playbackState.playing,
        isLoading: playbackState.processingState == AudioProcessingState.loading ||
            playbackState.processingState == AudioProcessingState.buffering,
        position: playbackState.updatePosition,
        bufferedPosition: playbackState.bufferedPosition,
        currentRadio: mediaItem != null
            ? RadioItem(
                id: mediaItem.id,
                name: mediaItem.title,
                logo: mediaItem.artUri.toString(),
                genres: mediaItem.artist ?? '',
                streamUrl: mediaItem.id,
                country: '',
                featured: false,
                color: '',
              )
            : null,
      ),
    );
  }

  /// Plays the specified radio station and shows the mini player.
  Future<void> playRadio(RadioItem radio, BuildContext context) async {
    if (!context.mounted) {
      debugPrint('AudioPlayerCubit: Context not mounted, aborting playRadio');
      return;
    }
    try {
      debugPrint('AudioPlayerCubit: Playing radio ${radio.id}');
      if (state.currentRadio?.id == radio.id && state.isPlaying) {
        await pauseRadio(context);
        return;
      }

      emit(state.copyWith(isLoading: true, currentRadio: radio, isMiniPlayerVisible: true));
      await _audioHandler.playRadio(radio, context);
      if (!context.mounted) {
        debugPrint('AudioPlayerCubit: Context not mounted after playRadio');
        return;
      }
      try {
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
        Provider.of<RadioProvider>(context, listen: false).addRecentlyPlayed(radioStation);
        Provider.of<RadioProvider>(context, listen: false).setLastPlayedTime(radio.id);
      } catch (e) {
        debugPrint('AudioPlayerCubit: Provider error for radio ${radio.id}: $e');
      }
      debugPrint('AudioPlayerCubit: Radio ${radio.id} playing');
      emit(
        state.copyWith(
          currentRadio: radio,
          isPlaying: true,
          isLoading: false,
          error: null,
          isMiniPlayerVisible: true,
        ),
      );
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error playing radio ${radio.id}: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error playing ${radio.name}',
          currentRadio: radio,
          isMiniPlayerVisible: true,
        ),
      );
    }
  }

  /// Pauses the currently playing radio.
  Future<void> pauseRadio(BuildContext context) async {
    if (!context.mounted) {
      debugPrint('AudioPlayerCubit: Context not mounted, aborting pauseRadio');
      return;
    }
    try {
      await _audioHandler.pause();
      debugPrint('AudioPlayerCubit: Radio ${state.currentRadio?.id} paused');
      emit(state.copyWith(isPlaying: false, isLoading: false));
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error pausing radio: $e');
    }
  }

  /// Resumes playback of the paused radio.
  Future<void> resumeRadio(BuildContext context) async {
    if (!context.mounted || state.currentRadio == null) {
      debugPrint('AudioPlayerCubit: Context not mounted or no radio selected, aborting resumeRadio');
      return;
    }
    try {
      debugPrint('AudioPlayerCubit: Resuming radio ${state.currentRadio!.id}');
      emit(state.copyWith(isLoading: true));
      await _audioHandler.play();
      debugPrint('AudioPlayerCubit: Radio ${state.currentRadio!.id} resumed');
      emit(state.copyWith(isPlaying: true, isLoading: false));
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error resuming radio ${state.currentRadio!.id}: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error resuming ${state.currentRadio!.name}',
        ),
      );
    }
  }

  /// Stops the radio playback and clears the current radio.
  Future<void> stopRadio() async {
    try {
      await _audioHandler.stop();
      debugPrint('AudioPlayerCubit: Radio stopped, emitting state');
      emit(
        state.copyWith(
          currentRadio: null,
          isPlaying: false,
          isLoading: false,
          error: null,
          position: Duration.zero,
          bufferedPosition: Duration.zero,
          isMiniPlayerVisible: false,
        ),
      );
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error stopping radio: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Error stopping radio',
          isMiniPlayerVisible: false,
        ),
      );
    }
  }

  /// Hides the mini player and stops the radio playback.
  Future<void> hideMiniPlayer() async {
    debugPrint('AudioPlayerCubit: Hiding mini player and stopping radio');
    await stopRadio();
  }

  /// Shows the mini player if a radio is selected.
  void showMiniPlayer() {
    if (state.currentRadio != null) {
      debugPrint('AudioPlayerCubit: Showing mini player for radio ${state.currentRadio!.id}');
      emit(state.copyWith(isMiniPlayerVisible: true));
    } else {
      debugPrint('AudioPlayerCubit: No radio selected, cannot show mini player');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _audioHandler.stop();
      debugPrint('AudioPlayerCubit: Audio handler stopped during cubit close');
    } catch (e) {
      debugPrint('AudioPlayerCubit: Error closing cubit: $e');
    }
    WidgetsBinding.instance.removeObserver(_AppLifecycleObserver());
    await super.close();
  }
}

/// Observes app lifecycle events to sync state on resume.
class _AppLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback? onResume;

  _AppLifecycleObserver({this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('AudioPlayerCubit: App resumed, syncing state');
      onResume?.call();
    }
  }
}