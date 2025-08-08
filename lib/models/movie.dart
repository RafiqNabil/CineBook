class Movie {
  final String title;
  final String imageUrl;
  final String overview;
  final int id;
  final double rating;
  final String genre; // Comma-separated genre names

  Movie({
    required this.title,
    required this.imageUrl,
    required this.overview,
    required this.id,
    required this.rating,
    required this.genre,
  });

  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    18: 'Drama',
    10749: 'Romance',
    27: 'Horror',
    878: 'Sci-Fi',
  };

  factory Movie.fromJson(Map<String, dynamic> json) {
    final genreIds = List<int>.from(json['genre_ids'] ?? []);
    final genreNames = genreIds
        .map((id) => genreMap[id])
        .where((name) => name != null)
        .cast<String>()
        .toList();

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No Overview',
      imageUrl: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : 'https://via.placeholder.com/300x450',
      rating: (json['vote_average'] ?? 0).toDouble(),
      genre: genreNames.isNotEmpty ? genreNames.join(', ') : 'Unknown',
    );
  }
  Map<String, dynamic> toJson() => {
    'title': title,
    'imageUrl': imageUrl,
    'overview': overview,
    'id': id,
    'rating': rating,
    'genre': genre,
  };
}
