class RadioStation {
  final String id;
  final String name;
  final String logo;
  final String genres;
  final String streamUrl;
  final String country;
  final bool featured;

  RadioStation({
    required this.id,
    required this.name,
    required this.logo,
    required this.genres,
    required this.streamUrl,
    required this.country,
    required this.featured,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      genres: json['genres'] ?? '',
      streamUrl: json['stream_url'] ?? '',
      country: json['country'] ?? '',
      featured: json['featured'] as bool? ?? false,
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
    };
  }
}
