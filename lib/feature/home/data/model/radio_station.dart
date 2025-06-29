class RadioStation {
  final String id;
  final String name;
  final String logo;
  final String genres;
  final String streamUrl;
  final String country;
  final bool featured;
  final String color;
  final String textColor; // ✅ New field

  RadioStation({
    required this.id,
    required this.name,
    required this.logo,
    required this.genres,
    required this.streamUrl,
    required this.country,
    required this.featured,
    required this.color,
    required this.textColor, // ✅ Add to constructor
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      genres: json['genres'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      country: json['country'] ?? '',
      featured: json['featured'] ?? false,
      color: json['color'] ?? '#FFFFFF',
      textColor: json['text_color'] ?? '#000000', // ✅ Add default text color
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'genres': genres,
      'stream_url': streamUrl,
      'country': country,
      'featured': featured,
      'color': color,
      'text_color': textColor, // ✅ Include in JSON output
    };
  }
}
