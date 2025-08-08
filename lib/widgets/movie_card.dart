import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../screens/movie_details_screen.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({required this.movie, super.key});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 0.97); // shrink on tap
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0); // restore size
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movie: widget.movie),
      ),
    );
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0); // restore if canceled
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Hero(
                  tag: 'movie-${movie.id}',
                  child: Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) =>
                        loadingProgress == null
                        ? child
                        : Center(child: CircularProgressIndicator()),
                    errorBuilder: (context, error, stackTrace) =>
                        Center(child: Icon(Icons.broken_image, size: 50)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                child: Column(
                  children: [
                    Text(
                      movie.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.genre} • ⭐ ${movie.rating.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
