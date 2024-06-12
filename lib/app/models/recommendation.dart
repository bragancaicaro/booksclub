class Recommendation {
  final String id;
  final String title;
  final String author;
  final int publication;
  final double rating;
  final int talkCount;
  final String? category;
  final String synopsis;

  Recommendation({
    required this.id,
    required this.title,
    required this.author,
    required this.publication,
    required this.rating,
    required this.talkCount,
    required this.category,
    required this.synopsis,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      publication: json['publication'],
      rating: json['rating'],
      talkCount: json['talk_count'],
      category: json['category_name'],
      synopsis: json['synopsis'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'publication': publication,
      'rating': rating,
      'talk_count': talkCount, 
      'category_name': category,
      'synopsis': synopsis,
    };
  }
  
}