import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();

  MyAudioHandler() {
    try {
      // Initialize audio session for background playback and interruptions
      _initializeAudioSession();

      _listenForCurrentSongIndexChanges();
      _audioPlayer.playbackEventStream.listen(_broadcastState);
      _audioPlayer.processingStateStream.listen((state) {
        log('MyAudioHandler: Processing state changed to $state');
        if (state == ProcessingState.completed) {
          stop();
        }
      });
      _audioPlayer.playerStateStream.listen((playerState) {
        log('MyAudioHandler: Player state - playing=${playerState.playing}');
      });

      log('MyAudioHandler: Initialized successfully');
    } catch (e) {
      log('MyAudioHandler: Initialization error: $e');
      rethrow;
    }
  }

  Future<void> _initializeAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      AudioSessionConfiguration(
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        avAudioSessionCategory: AVAudioSessionCategory.playback,
      ),
    );

    // Handle audio interruptions (e.g., phone calls)
    session.interruptionEventStream.listen((event) {
      log(
        'MyAudioHandler: Interruption event - began=${event.begin}, type=${event.type}',
      );
      if (event.begin) {
        // Interruption began (e.g., phone call)
        pause();
      } else {
        // Interruption ended
        if (_audioPlayer.playing == false && mediaItem.value != null) {
          play();
        }
      }
    });

    // Activate the audio session
    await session.setActive(true);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return ProgressiveAudioSource(Uri.parse(mediaItem.id));
  }

  void _listenForCurrentSongIndexChanges() {
    _audioPlayer.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      log('MyAudioHandler: Queue index changed to $index');
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
      androidCompactActionIndices: const [0, 1, 2],
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
    log(
      'MyAudioHandler: Broadcast state - playing=${state.playing}, processing=${state.processingState}',
    );
  }

  Future<void> playRadio(RadioItem radio) async {
    try {
      log('MyAudioHandler: Setting up radio ${radio.name}');
      final mediaItem = MediaItem(
        id: radio.streamUrl,
        title: radio.name,
        artist: radio.genres,
        artUri: Uri.parse(radio.logo),
        duration: null,
      );

      // Set the MediaItem first
      this.mediaItem.add(mediaItem);
      queue.add([mediaItem]);
      log('MyAudioHandler: MediaItem set - ${mediaItem.title}');

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
      log('MyAudioHandler: Loading state set for ${radio.name}');

      // Set audio source and play
      await _audioPlayer.setAudioSource(_createAudioSource(mediaItem));
      log('MyAudioHandler: Audio source set for ${radio.name}');

      await _audioPlayer.play();
      log('MyAudioHandler: Playing radio ${radio.name}');

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
      log('MyAudioHandler: Error playing radio ${radio.name}: $e');
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          playing: false,
        ),
      );
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _audioPlayer.play();
      log('MyAudioHandler: Playback started via notification');

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
      log('MyAudioHandler: Error playing: $e');
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      log('MyAudioHandler: Playback paused via notification');

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
      log('MyAudioHandler: Error pausing: $e');
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(EmptyAudioSource());

      queue.add([]);
      mediaItem.add(null);

      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.idle,
          playing: false,
          controls: [],
          systemActions: const {},
          androidCompactActionIndices: const [],
        ),
      );
      log('MyAudioHandler: Stopped successfully via notification');
    } catch (e) {
      log('MyAudioHandler: Error stopping player: $e');
      rethrow;
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      log('MyAudioHandler: Seek to $position');
    } catch (e) {
      log('MyAudioHandler: Error seeking: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    try {
      await _audioPlayer.seek(Duration.zero, index: index);
      await play();
      log('MyAudioHandler: Skipped to queue item $index');
    } catch (e) {
      log('MyAudioHandler: Error skipping to queue item: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToNext() async {
    try {
      await _audioPlayer.seekToNext();
      log('MyAudioHandler: Skipped to next');
    } catch (e) {
      log('MyAudioHandler: Error skipping to next: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _audioPlayer.seekToPrevious();
      log('MyAudioHandler: Skipped to previous');
    } catch (e) {
      log('MyAudioHandler: Error skipping to previous: $e');
      rethrow;
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
      // Deactivate audio session
      final session = await AudioSession.instance;
      await session.setActive(false);
      log('MyAudioHandler: Disposed successfully');
    } catch (e) {
      log('MyAudioHandler: Error disposing player: $e');
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
