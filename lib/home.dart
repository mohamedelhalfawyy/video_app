import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_app/preview.dart';

const API_KEY = 'AIzaSyAq1rJGie-D58qXt81zv6Pl9WffIb4uUwE';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';
  final TextEditingController _textEditingController = TextEditingController();
  String _header = 'Videos For You';
  bool _isLoading = true;
  bool _showClearIcon = false;
  bool _isDarkTheme = false;
  List<Map<String, dynamic>> _videos = [];
  int _currentPageIndex = 0;
  final int _videosPerPage = 5;

  @override
  void initState() {
    super.initState();
    _getPopularVideos();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void _getPopularVideos() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&maxResults=10&regionCode=US&key=$API_KEY'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['items'] as List<dynamic>;

      setState(() {
        _isLoading = false;
        _videos = videos
            .map((video) => {
                  'id': video['id'],
                  'title': video['snippet']['title'],
                  'description': video['snippet']['description'],
                  'thumbnail': video['snippet']['thumbnails']['high']['url'],
                })
            .toList();
      });
    } else {
      // handle error
      setState(() {
        _isLoading = false;
        _videos = [];
      });

      throw Exception('Failed to load videos');
    }
  }

  void _searchVideos(String query) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=10&q=$query&type=video&key=AIzaSyAq1rJGie-D58qXt81zv6Pl9WffIb4uUwE'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['items'] as List<dynamic>;

      setState(() {
        _isLoading = false;
        _videos = videos
            .map((video) => {
                  'id': video['id']['videoId'],
                  'title': video['snippet']['title'],
                  'description': video['snippet']['description'],
                  'thumbnail': video['snippet']['thumbnails']['high']['url'],
                })
            .toList();
      });
    } else {
      // handle error
      setState(() {
        _isLoading = false;
        _videos = [];
        throw Exception('Failed to load videos');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Video Preview App'),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleTheme,
          tooltip: 'Toggle Dark Mode',
          child: _isDarkTheme ? const Icon(Icons.light_mode) : const Icon(Icons.dark_mode),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _textEditingController,
                decoration:  InputDecoration(
                  suffixIcon: _showClearIcon ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _textEditingController.clear();
                        _showClearIcon = false;
                      });
                    },
                  ) : const Icon(Icons.search),
                  hintText: 'Search for videos',
                  filled: true,
                  fillColor: Colors.black12,
                  border:  const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(25.0),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _showClearIcon = value.isNotEmpty;
                  });
                  _searchQuery = value;
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _searchVideos(value);
                    setState(() {
                      _header = 'Results';
                    });
                  } else {
                    _getPopularVideos();
                    setState(() {
                      _header = 'Videos For You';
                    });
                  }
                },
              )
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              child:  Text(_header, style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
            ),
            const SizedBox(height: 10,),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : PageView.builder(
                      onPageChanged: (index) {
                        setState(() {
                          _currentPageIndex = index;
                        });
                      },
                      itemCount: (_videos.length / _videosPerPage).ceil(),
                      itemBuilder: (context, pageIndex) {
                        final startIndex = pageIndex * _videosPerPage;
                        final endIndex =
                            (startIndex + _videosPerPage) > _videos.length
                                ? _videos.length
                                : (startIndex + _videosPerPage);
                        final videos = _videos.sublist(startIndex, endIndex);

                        return ListView.builder(
                          itemCount: videos.length,
                          itemBuilder: (BuildContext context, int index) {
                            final video = videos[index];

                            return Column(
                              children: [
                                ListTile(
                                  leading: Image.network(video['thumbnail']),
                                  title: Text(video['title']),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PreviewPage(
                                          videoId: video['id'],
                                          videoName: video['title'],
                                          title: video['title'],
                                          description: video['description'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 25,)
                              ],
                            );
                          },
                        );
                      },
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                (_videos.length / _videosPerPage).ceil(),
                (int index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPageIndex == index
                          ? Theme.of(context).accentColor
                          : Theme.of(context).primaryColor.withOpacity(0.4),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
