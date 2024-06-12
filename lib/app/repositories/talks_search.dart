import 'dart:convert';
import 'package:booksclub/app/models/talk.dart';
import 'package:http/http.dart' as http;
import '../token/get_token.dart';

class TalksSearchManager {
  String? _nextPage;
  bool _isLoading = false;
  final String initialUrl;
  final List<Talk> _items = [];

  TalksSearchManager(this.initialUrl);

  bool get isLoading => _isLoading;

  List<Talk> get items => List.from(_items);

  /// Updates the URL used for fetching talks.
  void setUrl(String url) {
    _nextPage = null; // Reset next page when URL changes
    _items.clear(); // Clear existing talks before fetching new ones
    fetchItems(url: url);
  }

  Future<void> fetchItems({String? url}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    print(_isLoading);

    var requestUrl = Uri.parse(url ?? _nextPage ?? initialUrl);
    final response = await http.get(
      requestUrl,
      headers: {
        'Authorization': (await getToken()) ?? '',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    _isLoading = false;
    print(_isLoading);

    if (response.statusCode == 200) {
      print(response.body);
      Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      if (data.containsKey('results') && data['results'] is List) {
        List<dynamic> results = data['results'];
        if (results.isNotEmpty) {
          List<Talk> newItems =
              results.map((item) => Talk.fromJson(item)).toList();

          _items.addAll(newItems);
          if (data.containsKey('next') && data['next'] is String) {
            _nextPage = data['next'];
          } else {
            _nextPage = null;
          }
        }
      }
    } else {
      throw Exception('Failed to load items. Status code: ${response.statusCode}');
    }
  }

  Future<void> loadMoreItems() async {
    if (_nextPage != null) {
      await fetchItems(url: _nextPage!);
    }
  }

  void clear() {
    items.clear();
  }

  String? getNextPage() {
    return _nextPage;
  }

  void setIsLoading() {
    _isLoading = true;
  }
}