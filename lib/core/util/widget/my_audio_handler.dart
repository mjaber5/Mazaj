import 'package:audio_service/audio_service.dart';
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
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
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
      playbackState.add(
        playbackState.value.copyWith(
          errorCode: 1,
          errorMessage: 'Error playing radio: $e',
        ),
      );
    }
  }

  @override
  Future<void> play() async => _audioPlayer.play();

  @override
  Future<void> pause() async => _audioPlayer.pause();

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));
    queue.add([]);
    mediaItem.add(null);
    playbackState.add(
      playbackState.value.copyWith(processingState: AudioProcessingState.idle),
    );
  }

  @override
  Future<void> seek(Duration position) => _audioPlayer.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    await _audioPlayer.seek(Duration.zero, index: index);
    play();
  }

  @override
  Future<void> skipToNext() async => _audioPlayer.seekToNext();

  @override
  Future<void> skipToPrevious() async => _audioPlayer.seekToPrevious();

  Future<void> dispose() async {
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    queue.add([]);
    mediaItem.add(null);
  }
}
