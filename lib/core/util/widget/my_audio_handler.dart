import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  MyAudioHandler() {
    try {
      _listenForCurrentSongIndexChanges();
      _audioPlayer.playbackEventStream.listen(_broadcastState);
      _audioPlayer.processingStateStream.listen((state) {
        debugPrint('MyAudioHandler: Processing state changed to $state');
        if (state == ProcessingState.completed) {
          stop();
        }
      });
      _audioPlayer.playerStateStream.listen((playerState) {
        debugPrint(
          'MyAudioHandler: Player state - playing=${playerState.playing}',
        );
      });
      debugPrint('MyAudioHandler: Initialized successfully');
    } catch (e) {
      debugPrint('MyAudioHandler: Initialization error: $e');
      rethrow;
    }
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return ProgressiveAudioSource(Uri.parse(mediaItem.id));
  }

  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      debugPrint('MyAudioHandler: Queue index changed to $index');
      mediaItem.add(playlist[index]);
    });
  }

  void _broadcastState(PlaybackEvent event) {
    final state = playbackState.value.copyWith(
      controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
      },
      androidCompactActionIndices: const [0, 1, 2], // play/pause, stop
      processingState:
          const {
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
    );
    playbackState.add(state);
    debugPrint(
      'MyAudioHandler: Broadcast state - playing=${state.playing}, processing=${state.processingState}',
    );
  }

  Future<void> playRadio(RadioItem radio) async {
    try {
      debugPrint('MyAudioHandler: Setting up radio ${radio.name}');
      final mediaItem = MediaItem(
        id: radio.streamUrl,
        title: radio.name,
        artist: radio.genres,
        artUri: Uri.parse(radio.logo),
        duration: null, // Radio streams have no fixed duration
      );

      // Set the MediaItem first
      this.mediaItem.add(mediaItem);
      queue.add([mediaItem]);
      debugPrint('MyAudioHandler: MediaItem set - ${mediaItem.title}');

      // Update playback state to show loading
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.loading,
          playing: false,
          controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ),
      );
      debugPrint('MyAudioHandler: Loading state set for ${radio.name}');

      // Set audio source and play
      await _audioPlayer.setAudioSource(_createAudioSource(mediaItem));
      debugPrint('MyAudioHandler: Audio source set for ${radio.name}');

      await _audioPlayer.play();
      debugPrint('MyAudioHandler: Playing radio ${radio.name}');

      // Update playback state to show playing
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
          playing: true,
          controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ),
      );
    } catch (e) {
      debugPrint('MyAudioHandler: Error playing radio ${radio.name}: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          playing: false,
        ),
      );
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
      debugPrint('MyAudioHandler: Playback started via notification');

      // Update state to reflect playing
      playbackState.add(
        playbackState.value.copyWith(
          playing: true,
          processingState: AudioProcessingState.ready,
          controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ),
      );
    } catch (e) {
      debugPrint('MyAudioHandler: Error playing: $e');
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      debugPrint('MyAudioHandler: Playback paused via notification');

      // Update state to reflect paused
      playbackState.add(
        playbackState.value.copyWith(
          playing: false,
          processingState: AudioProcessingState.ready,
          controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ),
      );
    } catch (e) {
      debugPrint('MyAudioHandler: Error pausing: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(EmptyAudioSource());

      // Clear queue and media item
      queue.add([]);
      mediaItem.add(null);

      // Update state to reflect stopped
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
          controls: [],
          systemActions: const {},
          androidCompactActionIndices: const [],
        ),
      );
      debugPrint('MyAudioHandler: Stopped successfully via notification');
    } catch (e) {
      debugPrint('MyAudioHandler: Error stopping player: $e');
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      debugPrint('MyAudioHandler: Seek to $position');
    } catch (e) {
      debugPrint('MyAudioHandler: Error seeking: $e');
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      await play();
      debugPrint('MyAudioHandler: Skipped to queue item $index');
    } catch (e) {
      debugPrint('MyAudioHandler: Error skipping to queue item: $e');
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _audioPlayer.seekToNext();
      debugPrint('MyAudioHandler: Skipped to next');
    } catch (e) {
      debugPrint('MyAudioHandler: Error skipping to next: $e');
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
      debugPrint('MyAudioHandler: Skipped to previous');
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
          controls: [],
        ),
      );
      debugPrint('MyAudioHandler: Disposed successfully');
    } catch (e) {
      debugPrint('MyAudioHandler: Error disposing player: $e');
    }
  }
}

class EmptyAudioSource extends AudioSource {
  Future<void> prepare() async {}

  @override
  List<IndexedAudioSource> get sequence => const [];

  @override
  List<int> get shuffleIndices => const [];
}
