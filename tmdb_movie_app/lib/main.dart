
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MovieApp());
}

const String apiKey = 'YOUR_TMDB_API_KEY';

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MovieDescriptionScreen(movieId: 550),
    );
  }
}

class MovieDescriptionScreen extends StatefulWidget {
  final int movieId;

  const MovieDescriptionScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDescriptionScreen> createState() =>
      _MovieDescriptionScreenState();
}

class _MovieDescriptionScreenState
    extends State<MovieDescriptionScreen> {
  Map<String, dynamic>? movie;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMovie();
  }

  Future<void> fetchMovie() async {
    try {
      final url = Uri.https(
        'api.themoviedb.org',
        '/3/movie/${widget.movieId}',
        {'api_key': apiKey},
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: Check API key');
      }

      final data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        movie = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101018),
      appBar: AppBar(
        title: const Text('Movie Discovery'),
        backgroundColor: const Color(0xFF101018),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                )
              : buildDetails(),
    );
  }

  Widget buildDetails() {
    final posterPath = movie?['poster_path'];
    final backdropPath = movie?['backdrop_path'];

    final poster = posterPath == null
        ? null
        : 'https://image.tmdb.org/t/p/w500$posterPath';

    final backdrop = backdropPath == null
        ? null
        : 'https://image.tmdb.org/t/p/w1280$backdropPath';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (backdrop != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              backdrop,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: 30),
            ),
          ),
        const SizedBox(height: 20),
        if (poster != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                poster,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 20),
        Text(
          movie?['title'] ?? 'Movie',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '⭐ ${((movie?['vote_average'] ?? 0) as num).toStringAsFixed(1)} / 10',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.amber,
          ),
        ),
        const SizedBox(height: 8),
        Text('Release date: ${movie?['release_date'] ?? 'Unknown'}'),
        const SizedBox(height: 24),
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          movie?['overview'] ?? 'No description available.',
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
