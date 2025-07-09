import 'package:flutter/material.dart';
import 'api_service.dart';
import 'movie.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum MovieViewType { list, card }

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Movie> _movies = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';
  MovieViewType _currentViewType = MovieViewType.list;

  final List<String> _defaultMovieTitles = [
    'Barbie',
    'Spider-Man: Across the Spider-Verse',
    'John Wick: Chapter 4',
    'The Super Mario Bros. Movie',
    'Top Gun: Maverick',
    'Avatar: The Way of Water',
    'Black Panther: Wakanda Forever',
    'The Batman',
    'Spider-Man: No Way Home',
    'Dune',
    'Shang-Chi and the Legend of Ten Rings',
    'Encanto',
    'Tenet',
    'Soul',
    'The Invisible Man',
    'Avengers: Endgame',
    'Joker',
    'Frozen II',
    'Parasite',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDefaultMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchDefaultMovies() async {
    setState(() {
      _isLoading = true;
      _movies.clear();
      _currentSearchQuery = '';
    });

    List<Movie> fetchedMovies = [];
    for (String title in _defaultMovieTitles) {
      final movie = await _apiService.fetchMovieByTitle(title);
      if (movie != null) {
        fetchedMovies.add(movie);
      }
    }
    setState(() {
      _movies = fetchedMovies;
      _isLoading = false;
    });
  }

  Future<void> _searchMoviesByKeyword(String query) async {
    if (query.trim().isEmpty) {
      _fetchDefaultMovies();
      return;
    }

    setState(() {
      _isLoading = true;
      _movies.clear();
      _currentSearchQuery = query;
    });

    final List<Map<String, dynamic>> searchResults = await _apiService.searchMovies(query);

    List<Movie> fetchedMovies = [];
    if (searchResults.isNotEmpty) {
      for (var result in searchResults) {
        final String imdbId = result['imdbID'];
        final Movie? movie = await _apiService.fetchMovieById(imdbId);
        if (movie != null) {
          fetchedMovies.add(movie);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada film yang mengandung kata "$query".')),
      );
    }

    setState(() {
      _movies = fetchedMovies;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinelist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _fetchDefaultMovies,
            tooltip: 'Tampilkan Film Default',
          ),
          IconButton(
            icon: Icon(
              _currentViewType == MovieViewType.list ? Icons.grid_view : Icons.list,
            ),
            onPressed: () {
              setState(() {
                _currentViewType = _currentViewType == MovieViewType.list
                    ? MovieViewType.card
                    : MovieViewType.list;
              });
            },
            tooltip: _currentViewType == MovieViewType.list
                ? 'Ganti ke Tampilan Kartu'
                : 'Ganti ke Tampilan Daftar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari film...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchDefaultMovies();
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      _searchMoviesByKeyword(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _searchMoviesByKeyword(_searchController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          if (_currentSearchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Hasil Pencarian untuk: "${_currentSearchQuery}"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                'Film-film Pilihan:',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          const Divider(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movies.isEmpty
                ? const Center(child: Text('Tidak ada film yang ditemukan untuk kueri ini. Coba cari yang lain atau kembali ke daftar film default.'))
                : _currentViewType == MovieViewType.list
                ? _buildListView()
                : _buildCardView(),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          elevation: 2,
          child: ListTile(
            leading: movie.poster != 'N/A' && movie.poster.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image.network(
                movie.poster,
                width: 60,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.movie, size: 60);
                },
              ),
            )
                : const Icon(Icons.movie, size: 60),
            title: Text(
              movie.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(movie.year),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movie: movie),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCardView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.6,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
                    child: movie.poster != 'N/A' && movie.poster.isNotEmpty
                        ? Image.network(
                      movie.poster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.movie, size: 80, color: Colors.grey),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.movie, size: 80, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          movie.year,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}