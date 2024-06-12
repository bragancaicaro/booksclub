import 'dart:convert';
import 'package:booksclub/app/models/book.dart';
import 'package:http/http.dart' as http;
import '../token/get_token.dart';

class BooksManager {
  String? _nextPage;
  bool _isLoading = false;
  final String initialUrl;
  final List<Book> _items = [];

  BooksManager(this.initialUrl);

  bool get isLoading => _isLoading;

  List<Book> get items => List.from(_items);

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
          List<Book> newItems =
              results.map((item) => Book.fromJson(item)).toList();
          
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
  void clear () {
    _items.clear();
    items.clear();
  }
  String? getNextPage() {
    return _nextPage;
  }

  void setIsLoading() {
    _isLoading = true;
  }
}


