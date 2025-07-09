class Movie {
  final String title;
  final String year;
  final String poster;
  final String plot;
  final String director;
  final String actors;
  final String genre;
  final String imdbRating;

  Movie({
    required this.title,
    required this.year,
    required this.poster,
    required this.plot,
    required this.director,
    required this.actors,
    required this.genre,
    required this.imdbRating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      poster: json['Poster'] ?? 'N/A',
      plot: json['Plot'] ?? 'N/A',
      director: json['Director'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
    );
  }
}