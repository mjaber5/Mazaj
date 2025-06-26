// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:mazaj_radio/core/util/widget/audio_player_cubit.dart';
// import 'package:mazaj_radio/feature/collections/data/model/radio_item.dart';

// class FullPlayerScreen extends StatelessWidget {
//   final RadioItem radio;

//   const FullPlayerScreen({super.key, required this.radio});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.blue[800]!, Colors.blue[400]!],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 leading: IconButton(
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//                 title: Text(
//                   radio.name,
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: CachedNetworkImage(
//                   imageUrl: radio.logo,
//                   width: 250,
//                   height: 250,
//                   fit: BoxFit.cover,
//                   errorWidget:
//                       (context, url, error) =>
//                           const Icon(Icons.radio, size: 250),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text(
//                 radio.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               Text(
//                 radio.genres,
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               BlocBuilder<AudioPlayerCubit, AudioPlayerState>(
//                 builder: (context, state) {
//                   final isPlaying =
//                       state.currentRadio?.id == radio.id && state.isPlaying;
//                   final cubit = context.read<AudioPlayerCubit>();
//                   return Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(
//                           Icons.stop,
//                           color: Colors.white,
//                           size: 40,
//                         ),
//                         onPressed: () => cubit.stopRadio(context),
//                       ),
//                       const SizedBox(width: 32),
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color:
//                               isPlaying ? Colors.redAccent : Colors.blueAccent,
//                         ),
//                         child: IconButton(
//                           icon: Icon(
//                             isPlaying ? Icons.pause : Icons.play_arrow,
//                             color: Colors.white,
//                             size: 40,
//                           ),
//                           onPressed: () {
//                             if (isPlaying) {
//                               cubit.pauseRadio(context);
//                             } else {
//                               cubit.playRadio(radio, context);
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
