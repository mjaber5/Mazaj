// audio_player_state.dart
part of 'audio_player_cubit.dart';

class AudioPlayerState {
  final RadioItem? currentRadio;
  final bool isPlaying;
  final bool isLoading;
  final String? error;

  const AudioPlayerState({
    this.currentRadio,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
  });

  AudioPlayerState copyWith({
    RadioItem? currentRadio,
    bool? isPlaying,
    bool? isLoading,
    String? error,
  }) {
    return AudioPlayerState(
      currentRadio: currentRadio ?? this.currentRadio,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
