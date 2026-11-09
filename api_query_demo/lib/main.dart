
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Query Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
      ),
      home: const QueryHomePage(),
    );
  }
}

class QueryHomePage extends StatefulWidget {
  const QueryHomePage({super.key});

  @override
  State<QueryHomePage> createState() => _QueryHomePageState();
}

class _QueryHomePageState extends State<QueryHomePage> {
  final TextEditingController userIdController =
      TextEditingController(text: '1');

  bool isLoading = false;
  bool hasSearched = false;

  List<dynamic> posts = [];

  String? errorMessage;
  String requestUrl = '';

  int? statusCode;

  Future<void> searchPosts() async {
    final userId = int.tryParse(
      userIdController.text.trim(),
    );

    // Validate User ID
    if (userId == null || userId < 1 || userId > 10) {
      setState(() {
        errorMessage = 'Enter a valid User ID between 1 and 10.';
        posts = [];
        hasSearched = true;
        statusCode = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      posts = [];
      statusCode = null;
      hasSearched = true;
    });

    try {
      // 1. Create API URL using query parameters
      final uri = Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        {
          'userId': userId.toString(),
        },
      );

      requestUrl = uri.toString();

      // 2. Send GET request
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 20),
      );

      if (!mounted) return;

      setState(() {
        statusCode = response.statusCode;
      });

      // 3. Check response status
      if (response.statusCode == 200) {
        // 4. Decode JSON
        final data = jsonDecode(response.body);

        if (data is! List) {
          throw Exception('Invalid API response format.');
        }

        // 5. Display posts
        setState(() {
          posts = data;
          errorMessage = null;
        });
      } else {
        throw Exception(
          'HTTP Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        posts = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'API Query Parameters',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          // SEARCH SECTION
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const Icon(
                  Icons.search,
                  size: 70,
                  color: Colors.blue,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Search User Posts',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: userIdController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => searchPosts(),
                  decoration: InputDecoration(
                    labelText: 'Enter User ID (1-10)',
                    hintText: 'Example: 1',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : searchPosts,
                    icon: const Icon(Icons.search),
                    label: Text(
                      isLoading ? 'Searching...' : 'SEARCH POSTS',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // RESULTS SECTION
          Expanded(
            child: isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 15),
                        Text('Fetching posts from API...'),
                      ],
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 55,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: searchPosts,
                                child: const Text('TRY AGAIN'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : posts.isNotEmpty
                        ? Column(
                            children: [
                              // RESPONSE DETAILS
                              Container(
                                width: double.infinity,
                                color: Colors.green.shade50,
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'HTTP Status: $statusCode',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Posts found: ${posts.length}',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Request URL:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SelectableText(
                                      requestUrl,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // POSTS LIST
                              Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(15),
                                  itemCount: posts.length,
                                  itemBuilder: (context, index) {
                                    final post = posts[index];

                                    return Card(
                                      margin: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'POST ID: ${post['id']}',
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            Text(
                                              post['title'].toString(),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                    FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(height: 8),

                                            Text(
                                              post['body'].toString(),
                                            ),

                                            const SizedBox(height: 10),

                                            Text(
                                              'User ID: ${post['userId']}',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cloud_download_outlined,
                                  size: 75,
                                  color: Colors.blue.shade300,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  hasSearched
                                      ? 'No posts found.'
                                      : 'Search posts using a User ID',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
