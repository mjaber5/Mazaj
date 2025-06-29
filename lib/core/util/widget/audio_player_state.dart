part of 'audio_player_cubit.dart';

/// Represents the state of the audio player.
class AudioPlayerState {
  final RadioItem? currentRadio;
  final bool isPlaying;
  final bool isLoading;
  final String? error;
  final Duration position;
  final Duration bufferedPosition;
  final bool isMiniPlayerVisible;

  const AudioPlayerState({
    this.currentRadio,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
    this.position = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isMiniPlayerVisible = true,
  });

  /// Creates a new state with updated values, preserving unchanged ones.
  AudioPlayerState copyWith({
    RadioItem? currentRadio,
    bool? isPlaying,
    bool? isLoading,
    String? error,
    Duration? position,
    Duration? bufferedPosition,
    bool? isMiniPlayerVisible,
  }) {
    return AudioPlayerState(
      currentRadio: currentRadio ?? this.currentRadio,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      position: position ?? this.position,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isMiniPlayerVisible: isMiniPlayerVisible ?? this.isMiniPlayerVisible,
    );
  }
}
