class Search {

  final String id;
  final String title;
  final String author;
  final int publication;
  final String? category;
  final String synopsis;
  final double rating;
  final int talkCount;


  Search({
    required this.id,
    required this.title,
    required this.author,
    required this.publication,
    required this.category,
    required this.synopsis,
    required this.rating,
    required this.talkCount,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    return Search(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publication: json['publication'],
      synopsis: json['synopsis'],
      category: json['category_name'],
      rating: json['rating'],
      talkCount: json['talk_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title, 
      'author': author, 
      'publication': publication,
      'synopsis': synopsis, 
      'category_name': category,
      'rating': rating,
      'talk_count': talkCount, 
    };
  }
}