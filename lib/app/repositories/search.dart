import 'dart:convert';
import 'package:http/http.dart' as http;
import '../token/get_token.dart';
import '../models/search.dart';

class SearchManager {
  String? _nextPage;
  bool _isLoading = false;
  final String initialUrl;
  final List<Search> _items = [];

  SearchManager(this.initialUrl);

  bool get isLoading => _isLoading;

  List<Search> get items => List.unmodifiable(_items);

  Future<void> fetchItems({String? url}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    var requestUrl = Uri.parse(url ?? _nextPage ?? initialUrl);
    final response = await http.get(
      requestUrl,
      headers: {
        'Authorization': (await getToken()) ?? '',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    _isLoading = false;
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes, allowMalformed: true));
      if (data.containsKey('results') && data['results'] is List) {
        final List<dynamic> results = data['results'];
        if (results.isNotEmpty) {
          final List<Search> newItems =
              results.map((item) => Search.fromJson(item)).toList();
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
    await fetchItems();
  }

  String? getNextPage() {
    return _nextPage;
  }

  void clear() {
    _items.clear();
  }
}


