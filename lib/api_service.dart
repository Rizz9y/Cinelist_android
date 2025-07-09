import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie.dart';

class ApiService {
  static const String _apiKey = '57af3a9e';
  static const String _baseUrl = 'http://www.omdbapi.com/';

  Future<Movie?> fetchMovieByTitle(String title) async {
    final uri = Uri.parse('$_baseUrl?t=$title&apikey=$_apiKey');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return Movie.fromJson(data);
        } else {
          print('Error fetching movie $title: ${data['Error']}');
          return null;
        }
      } else {
        print('Failed to load movie $title. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception while fetching movie $title: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final uri = Uri.parse('$_baseUrl?s=$query&apikey=$_apiKey');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['Response'] == 'True' && data['Search'] != null) {
          return List<Map<String, dynamic>>.from(data['Search']);
        } else {
          print('Error searching movies for "$query": ${data['Error'] ?? 'No results'}');
          return [];
        }
      } else {
        print('Failed to search movies for "$query". Status code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception while searching movies for "$query": $e');
      return [];
    }
  }

  Future<Movie?> fetchMovieById(String imdbId) async {
    final uri = Uri.parse('$_baseUrl?i=$imdbId&apikey=$_apiKey');
    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return Movie.fromJson(data);
        } else {
          print('Error fetching movie details for ID $imdbId: ${data['Error']}');
          return null;
        }
      } else {
        print('Failed to load movie details for ID $imdbId. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception while fetching movie details for ID $imdbId: $e');
      return null;
    }
  }
}