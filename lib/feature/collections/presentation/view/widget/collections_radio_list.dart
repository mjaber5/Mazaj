import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mazaj_radio/core/util/constant/colors.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class CollectionsRadioList extends StatefulWidget {
  final List<RadioItem> radios;
  const CollectionsRadioList({super.key, required this.radios});

  @override
  State<CollectionsRadioList> createState() => _CollectionsRadioListState();
}

class _CollectionsRadioListState extends State<CollectionsRadioList> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playRadio(RadioItem radio) async {
    try {
      if (_currentlyPlaying == radio.id) {
        // Pause if tapped again
        await _audioPlayer.stop();
        setState(() {
          _currentlyPlaying = null;
        });
        return;
      }

      await _audioPlayer.setUrl(radio.streamUrl);
      await _audioPlayer.play();
      setState(() {
        _currentlyPlaying = radio.id;
      });
    } catch (e) {
      debugPrint('Failed to play radio: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error playing ${radio.name}')));
    }
  }

  String safeImageUrl(String url) {
    if (url.contains('placehold.co')) {
      return '$url&format=png';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.radios.length,
      itemBuilder: (context, index) {
        final radio = widget.radios[index];
        final isPLaying = _currentlyPlaying == radio.id;

        return GestureDetector(
          onTap: () => _playRadio(radio),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.accentColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      safeImageUrl(radio.logo),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.radio),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          radio.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          radio.genres,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(
                        isPLaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.black,
                      ),
                      onPressed:
                          () => _playRadio(radio), // ← Call play function here
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
