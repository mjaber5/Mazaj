import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

class FullPlayerScreen extends StatefulWidget {
  final RadioItem radio;

  const FullPlayerScreen({super.key, required this.radio});

  @override
  State<FullPlayerScreen> createState() => _FullPlayerScreenState();
}

class _FullPlayerScreenState extends State<FullPlayerScreen>
    with SingleTickerProviderStateMixin {
  double _volume = 0.5;

  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radio = widget.radio;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: SizedBox(
          height: 22,
          child: Marquee(
            text: radio.name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            velocity: 30,
            blankSpace: 50,
            pauseAfterRound: const Duration(seconds: 1),
            startPadding: 10,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade900, Colors.blueAccent.shade400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: CachedNetworkImage(
                    imageUrl: radio.logo,
                    width: 250,
                    height: 250,
                    fit: BoxFit.cover,
                    errorWidget:
                        (context, url, error) => const Icon(
                          Icons.radio,
                          size: 200,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (radio.genres.isNotEmpty)
                Text(
                  radio.genres,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              const SizedBox(height: 24),

              // 🎵 Visualizer
              SizedBox(
                height: 50,
                child: AnimatedBuilder(
                  animation: _visualizerController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        final height =
                            (20 + index * 2) * _visualizerController.value;
                        return Container(
                          width: 4,
                          height: height.clamp(10.0, 50.0),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 🎚️ Volume Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      "Volume",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Slider(
                      value: _volume,
                      onChanged: (value) {
                        setState(() => _volume = value);
                        // Here you can connect to audio service to control volume.
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white38,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 🔊 Playback Controls
              BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
                builder: (context, state) {
                  final isPlaying =
                      state.currentRadio?.id == radio.id && state.isPlaying;
                  final cubit = context.read<AudioPlayerCubit>();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.stop,
                        color: Colors.white70,
                        onPressed: () => cubit.stopRadio(context),
                      ),
                      const SizedBox(width: 40),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  isPlaying
                                      ? Colors.redAccent.withOpacity(0.5)
                                      : Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: _buildControlButton(
                          icon: isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          background:
                              isPlaying ? Colors.redAccent : Colors.blueAccent,
                          onPressed: () {
                            isPlaying
                                ? cubit.pauseRadio(context)
                                : cubit.playRadio(radio, context);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white,
    Color? background,
  }) {
    return ClipOval(
      child: Material(
        color: background ?? Colors.transparent,
        child: InkWell(
          splashColor: Colors.white24,
          onTap: onPressed,
          child: SizedBox(
            width: 70,
            height: 70,
            child: Icon(icon, color: color, size: 36),
          ),
        ),
      ),
    );
  }
}
