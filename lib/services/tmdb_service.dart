import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TMDbService {
  final String _baseUrl = 'https://api.themoviedb.org/3';
  final String _apiKey = dotenv.env['TMDB_API_KEY'] ?? '';

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List movies = json['results'];

      return movies.map((m) => Movie.fromJson(m)).toList();
    } else {
      throw Exception('Failed to fetch movies');
    }
  }
}
