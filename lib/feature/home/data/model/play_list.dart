// import 'dart:ui';

// class Playlist {
//   final String title;
//   final String subtitle; // genre
//   final int songCount;
//   final Color color;

//   Playlist({
//     required this.title,
//     required this.subtitle,
//     required this.songCount,
//     required this.color,
//   });

//   factory Playlist.fromJson(Map<String, dynamic> json) {
//     return Playlist(
//       title: json['name'],
//       subtitle: json['genres'],
//       songCount: 1, // Assuming each radio = 1 "song" entry
//       color: _hexToColor(json['color'] ?? '#000000'),
//     );
//   }

//   static Color _hexToColor(String hex) {
//     hex = hex.replaceAll("#", "");
//     if (hex.length == 6) hex = "FF$hex";
//     return Color(int.parse(hex, radix: 16));
//   }
// }
