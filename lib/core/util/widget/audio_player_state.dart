part of 'audio_player_cubit.dart';

class AudioPlayerState {
  final RadioItem? currentRadio;
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  final Duration position;
  final Duration bufferedPosition;

  const AudioPlayerState({
    this.currentRadio,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
  });

  AudioPlayerState copyWith({
    RadioItem? currentRadio,
    bool? isPlaying,
    bool? isLoading,
    String? error,
    Duration? position,
    Duration? bufferedPosition,
  }) {
    return AudioPlayerState(
      currentRadio: currentRadio ?? this.currentRadio,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
    );
  }
}
