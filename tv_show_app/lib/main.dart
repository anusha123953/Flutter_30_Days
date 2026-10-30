
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TVShowApp());
}

class TVShowApp extends StatelessWidget {
  const TVShowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TV Show Discovery',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101018),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List shows = [];
  bool loading = true;
  String error = '';

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchShows('girls');
  }

  Future<void> fetchShows(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final url = Uri.parse(
        'https://api.tvmaze.com/search/shows?q=${Uri.encodeQueryComponent(query)}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          shows = jsonDecode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load shows');
      }
    } catch (e) {
      setState(() {
        error = 'Unable to load shows. Check your internet.';
        loading = false;
      });
    }
  }

  String cleanText(String? value) {
    return (value ?? 'No description available.')
        .replaceAll(RegExp(r'<[^>]*>'), '');
  }

  void showDetails(dynamic show) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252536),
        title: Text(show['name'] ?? 'TV Show'),
        content: SingleChildScrollView(
          child: Text(cleanText(show['summary'])),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TV SHOW DISCOVERY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF191927),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller,
              onSubmitted: (value) => fetchShows(value),
              decoration: InputDecoration(
                hintText: 'Search TV shows...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => fetchShows(controller.text),
                ),
                filled: true,
                fillColor: const Color(0xFF252536),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error.isNotEmpty
                    ? Center(child: Text(error))
                    : shows.isEmpty
                        ? const Center(
                            child: Text('No shows found'),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final columns = (constraints.maxWidth / 220)
                                  .floor()
                                  .clamp(2, 6);

                              return GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: shows.length,
                                itemBuilder: (context, index) {
                                  final show = shows[index]['show'];
                                  final image =
                                      show['image']?['medium'];

                                  return GestureDetector(
                                    onTap: () => showDetails(show),
                                    child: Card(
                                      color: const Color(0xFF202031),
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 180,
                                            width: double.infinity,
                                            child: image != null
                                                ? Image.network(
                                                    image,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            const Icon(
                                                      Icons.tv,
                                                      size: 50,
                                                    ),
                                                  )
                                                : const Icon(
                                                    Icons.tv,
                                                    size: 50,
                                                  ),
                                          ),

                                          Padding(
                                            padding:
                                                const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  show['name'] ??
                                                      'Unknown',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  '⭐ ${show['rating']?['average'] ?? 'N/A'}',
                                                  style: const TextStyle(
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  (show['genres'] as List?)
                                                          ?.join(', ') ??
                                                      'No genres',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

