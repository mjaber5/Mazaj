class RadioItem {
  final String id;
  final String name;
  final String logo;
  final String genres;
  final String streamUrl;
  final String country;
  final bool featured;
  final String color;
  final String textColor;

  RadioItem({
    required this.id,
    required this.name,
    required this.logo,
    required this.genres,
    required this.streamUrl,
    required this.country,
    required this.featured,
    required this.color,
    required this.textColor,
  });

  factory RadioItem.fromJson(Map<String, dynamic> json) {
    return RadioItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      genres: json['genres'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      country: json['country'] ?? '',
      featured: json['featured'] ?? false,
      color: json['color'] ?? '',
      textColor: json['text_color'] ?? '#000000',
    );
  }
}
