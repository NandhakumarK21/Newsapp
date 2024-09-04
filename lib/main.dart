import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: NewsPage(),
    );
  }
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List articles = [];
  List favorites = [];
  int selectedIndex = 0; // 0 for News, 1 for Favs

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url =
        'https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=fbce903851bc4dd3a109ba03631f60d0';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        articles = data['articles'];
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: ToggleButtons(
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: (int newIndex) {
                setState(() {
                  selectedIndex = newIndex;
                });
              },
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.article,
                          color: selectedIndex == 0
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'News',
                        style: TextStyle(
                          fontSize: 30,
                          color: selectedIndex == 0
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.grey,
                          fontWeight: selectedIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(Icons.favorite,
                          color: selectedIndex == 1
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Favs',
                        style: TextStyle(
                          fontSize: 30,
                          color: selectedIndex == 1
                              ? const Color.fromARGB(255, 0, 0, 0)
                              : Colors.grey,
                          fontWeight: selectedIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              borderRadius: BorderRadius.circular(8),
              selectedBorderColor: const Color.fromARGB(255, 160, 162, 163),
              fillColor:
                  const Color.fromARGB(255, 160, 162, 163).withOpacity(0.1),
              color: Colors.black,
              selectedColor: const Color.fromARGB(255, 160, 162, 163),
              constraints: BoxConstraints(minHeight: 40.0),
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: selectedIndex == 0 ? buildNewsList() : buildFavsList(),
      ),
    );
  }

  Widget buildNewsList() {
    return articles.isEmpty
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Dismissible(
                  key: Key(article['title']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red[100],
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.red),
                        SizedBox(height: 4),
                        Text(
                          'Add to\nFavorite',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      favorites.add(article);
                      articles.removeAt(index);
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to favorites'),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0), // Reduced border radius
                        child: Image.network(
                          article['urlToImage'] ?? '',
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/placeholder.png',
                              width: 80,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                      title: Text(
                        article['title'] ?? 'No Title',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article['description'] ?? 'No Description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 14),
                              SizedBox(width: 4),
                              Text(
                                article['publishedAt'] ?? '',
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailPage(
                              article: article,
                              isFavorite: favorites.contains(article),
                              onFavoriteToggle: (isFavorite) {
                                setState(() {
                                  if (isFavorite) {
                                    favorites.add(article);
                                  } else {
                                    favorites.remove(article);
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget buildFavsList() {
    return favorites.isEmpty
        ? Center(child: Text('No favorites yet'))
        : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final article = favorites[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0), // Reduced border radius
                      child: Image.network(
                        article['urlToImage'] ?? '',
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.png',
                            width: 80,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    title: Text(
                      article['title'] ?? 'No Title',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article['description'] ?? 'No Description',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 14),
                            SizedBox(width: 4),
                            Text(
                              article['publishedAt'] ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(
                            article: article,
                            isFavorite: favorites.contains(article),
                            onFavoriteToggle: (isFavorite) {
                              setState(() {
                                if (isFavorite) {
                                  favorites.add(article);
                                } else {
                                  favorites.remove(article);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
  }
}

class ArticleDetailPage extends StatefulWidget {
  final Map<String, dynamic> article;
  final bool isFavorite;
  final Function(bool) onFavoriteToggle;

  ArticleDetailPage({
    required this.article,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
      widget.onFavoriteToggle(isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0), // Border radius for the image
                  child: Image.network(
                    widget.article['urlToImage'] ?? '',
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset('assets/placeholder.png');
                    },
                    width: double.infinity,
                    height: 200, // Adjusted image height
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 30, // Size of the icon
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              widget.article['title'] ?? 'No Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 14),
                SizedBox(width: 4),
                Text(
                  widget.article['publishedAt'] ?? '',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              widget.article['content'] ?? 'No Content',
            ),
          ],
        ),
      ),
    );
  }
}

