import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';
import 'package:mazaj_radio/feature/home/data/model/radio_station.dart';
import 'package:mazaj_radio/feature/home/presentation/view_model/radio_provider.dart';
import 'package:provider/provider.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _audioPlayer = AudioPlayer();
  BuildContext? _context; // Store context for RadioProvider access

  MyAudioHandler() {
    try {
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

  // Set context for accessing RadioProvider
  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> _initializeAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        avAudioSessionCategory: AVAudioSessionCategory.playback,
      ),
    );

    session.interruptionEventStream.listen((event) {
      log(
        'MyAudioHandler: Interruption event - began=${event.begin}, type=${event.type}',
      );
      if (event.begin) {
        pause();
      } else {
        if (_audioPlayer.playing == false && mediaItem.value != null) {
          play();
        }
      }
    });

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
      controls: [
        MediaControl.skipToPrevious,
        _audioPlayer.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.play,
        MediaAction.pause,
        MediaAction.stop,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [
        0,
        1,
        2,
      ], // Previous, Play/Pause, Next
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

  Future<void> playRadio(RadioItem radio, BuildContext context) async {
    try {
      log('MyAudioHandler: Setting up radio ${radio.name}');
      setContext(context); // Store context for RadioProvider access
      final logoUri =
          _validateImageUrl(radio.logo)
              ? Uri.parse(radio.logo)
              : Uri.parse('asset:///assets/images/splash-screen.png');

      final mediaItem = MediaItem(
        id: radio.streamUrl,
        title: radio.name,
        artist: radio.genres.isNotEmpty ? radio.genres : 'Radio Station',
        album: radio.country.isNotEmpty ? radio.country : 'Mazaj Radio',
        artUri: logoUri,
        duration: null,
        extras: {
          'country': radio.country,
          'featured': radio.featured,
          'id': radio.id,
        },
      );

      this.mediaItem.add(mediaItem);
      queue.add([mediaItem]);
      log(
        'MyAudioHandler: MediaItem set - ${mediaItem.title}, artUri=${mediaItem.artUri}',
      );

      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.loading,
          playing: false,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
          },
          androidCompactActionIndices: const [0, 1, 2],
        ),
      );
      log('MyAudioHandler: Loading state set for ${radio.name}');

      await _audioPlayer.setAudioSource(_createAudioSource(mediaItem));
      log('MyAudioHandler: Audio source set for ${radio.name}');

      await _audioPlayer.play();
      log('MyAudioHandler: Playing radio ${radio.name}');

      // Update recently played
      if (_context != null) {
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

      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.ready,
          playing: true,
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
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
          errorMessage: 'Failed to play ${radio.name}',
        ),
      );
      rethrow;
    }
  }

  bool _validateImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          (url.toLowerCase().endsWith('.png') ||
              url.toLowerCase().endsWith('.jpg') ||
              url.toLowerCase().endsWith('.jpeg'));
    } catch (e) {
      log('MyAudioHandler: Invalid image URL: $url, error: $e');
      return false;
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
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
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
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.play,
            MediaAction.pause,
            MediaAction.stop,
            MediaAction.skipToNext,
            MediaAction.skipToPrevious,
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
      if (_context == null) {
        log('MyAudioHandler: Context not set, cannot skip to next');
        return;
      }
      final radioProvider = Provider.of<RadioProvider>(
        _context!,
        listen: false,
      );
      final currentRadioId = mediaItem.value?.extras?['id'] as String?;
      if (currentRadioId == null) {
        log('MyAudioHandler: No current radio to skip from');
        return;
      }
      final nextRadio = radioProvider.getNextStation(currentRadioId);
      if (nextRadio != null) {
        await playRadio(
          RadioItem(
            id: nextRadio.id,
            name: nextRadio.name,
            logo: nextRadio.logo,
            genres: nextRadio.genres,
            streamUrl: nextRadio.streamUrl,
            country: nextRadio.country,
            featured: nextRadio.featured,
            color: nextRadio.color,
          ),
          _context!,
        );
        log('MyAudioHandler: Skipped to next radio: ${nextRadio.name}');
      } else {
        log('MyAudioHandler: No next radio station available');
      }
    } catch (e) {
      log('MyAudioHandler: Error skipping to next: $e');
      rethrow;
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      if (_context == null) {
        log('MyAudioHandler: Context not set, cannot skip to previous');
        return;
      }
      final radioProvider = Provider.of<RadioProvider>(
        _context!,
        listen: false,
      );
      final currentRadioId = mediaItem.value?.extras?['id'] as String?;
      if (currentRadioId == null) {
        log('MyAudioHandler: No current radio to skip from');
        return;
      }
      final prevRadio = radioProvider.getPreviousStation(currentRadioId);
      if (prevRadio != null) {
        await playRadio(
          RadioItem(
            id: prevRadio.id,
            name: prevRadio.name,
            logo: prevRadio.logo,
            genres: prevRadio.genres,
            streamUrl: prevRadio.streamUrl,
            country: prevRadio.country,
            featured: prevRadio.featured,
            color: prevRadio.color,
          ),
          _context!,
        );
        log('MyAudioHandler: Skipped to previous radio: ${prevRadio.name}');
      } else {
        log('MyAudioHandler: No previous radio station available');
      }
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
