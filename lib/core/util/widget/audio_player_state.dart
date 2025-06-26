part of 'audio_player_cubit.dart';

class AudioPlayerState {
  final RadioItem? currentRadio;
  final bool isPlaying;
  final String? error;

  const AudioPlayerState({
    this.currentRadio,
    this.isPlaying = false,
    this.error,
  });

  AudioPlayerState copyWith({
    RadioItem? currentRadio,
    bool? isPlaying,
    String? error,
  }) {
    return AudioPlayerState(
      currentRadio: currentRadio ?? this.currentRadio,
      isPlaying: isPlaying ?? this.isPlaying,
      error: error,
    );
  }
}
