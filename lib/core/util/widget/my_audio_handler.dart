import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  MyAudioHandler() {
    _listenForCurrentSongIndexChanges();
    _audioPlayer.playbackEventStream.listen(_broadcastState);
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        stop();
      }
    });
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return ProgressiveAudioSource(Uri.parse(mediaItem.id));
  }

  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      mediaItem.add(playlist[index]);
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0],
        processingState:
            {
              ProcessingState.idle: AudioProcessingState.idle,
              ProcessingState.loading: AudioProcessingState.loading,
              ProcessingState.buffering: AudioProcessingState.buffering,
              ProcessingState.ready: AudioProcessingState.ready,
              ProcessingState.completed: AudioProcessingState.completed,
            }[_audioPlayer.processingState]!,
        playing: _audioPlayer.playing,
        updatePosition: _audioPlayer.position,
        bufferedPosition: _audioPlayer.bufferedPosition,
        speed: _audioPlayer.speed,
        queueIndex: event.currentIndex,
      ),
    );
  }

  Future<void> playRadio(RadioItem radio) async {
    try {
      final mediaItem = MediaItem(
        id: radio.streamUrl,
        title: radio.name,
        artist: radio.genres,
        artUri: Uri.parse(radio.logo),
      );

      await _audioPlayer.setAudioSource(_createAudioSource(mediaItem));
      final newQueue = [mediaItem];
      queue.add(newQueue);
      this.mediaItem.add(mediaItem);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('MyAudioHandler: Error playing radio: $e');
      playbackState.add(
        playbackState.value.copyWith(
          errorCode: 1,
          errorMessage: 'Error playing radio: $e',
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('MyAudioHandler: Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('MyAudioHandler: Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      // Ensure the player is not loading to avoid "Loading interrupted"
      if (_audioPlayer.processingState == ProcessingState.loading ||
          _audioPlayer.processingState == ProcessingState.buffering) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.stop();
      // Clear the audio source safely
      await _audioPlayer.setAudioSource(EmptyAudioSource());
      queue.add([]);
      mediaItem.add(null);
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
        ),
      );
      debugPrint('MyAudioHandler: Stopped successfully');
    } catch (e) {
      debugPrint('MyAudioHandler: Error stopping player: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('MyAudioHandler: Error seeking: $e');
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      await play();
    } catch (e) {
      debugPrint('MyAudioHandler: Error skipping to queue item: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _audioPlayer.seekToNext();
    } catch (e) {
      debugPrint('MyAudioHandler: Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
    } catch (e) {
      debugPrint('MyAudioHandler: Error skipping to previous: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(EmptyAudioSource());
      await _audioPlayer.dispose();
      queue.add([]);
      mediaItem.add(null);
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
        ),
      );
      debugPrint('MyAudioHandler: Disposed successfully');
    } catch (e) {
      debugPrint('MyAudioHandler: Error disposing player: $e');
    }
  }
}

// Define an EmptyAudioSource for safe clearing
class EmptyAudioSource extends AudioSource {
  Future<void> load() async {}

  @override
  List<IndexedAudioSource> get sequence => const [];

  @override
  List<int> get shuffleIndices => const [];
}
