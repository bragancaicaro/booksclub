
class Book {
  final String id;
  final String title;
  final String author;
  final String synopsis;
  final int publication;
  final double rating;
  final Category? category;
  final dynamic following;
  final dynamic read;
  final dynamic saved;
  final int followCount;
  final int readCount;
  final int saveCount;
  final int talkCount;
  final int imageCount;
  final dynamic update;

  Book({required this.id, required this.title, required this.author, required this.synopsis, required this.publication, required this.category, this.following, this.read, this.saved, required this.followCount, required this.readCount, required this.saveCount, required this.talkCount, required this.imageCount, this.update, required this.rating});


  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      synopsis: json['synopsis'],
      publication: json['publication'],
      category: json['category'] != null ? Category.fromJson(json['category'] as Map<String, dynamic>) : null,
      following: json['following'],
      read: json['read'],
      saved: json['saved'],
      followCount: json['follow_count'],
      readCount: json['read_count'],
      saveCount: json['save_count'],
      talkCount: json['talk_count'],
      imageCount: json['image_count'],
      rating: json['rating'],
      update: json['update'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title, 
      'author': author, 
      'synopsis': synopsis, 
      'publication': publication, 
      'category': category,
      'following': following, 
      'read': read, 
      'saved': saved, 
      'follow_count': followCount, 
      'read_count': readCount, 
      'save_count': saveCount, 
      'talk_count': talkCount, 
      'image_count': imageCount,
      'rating': rating,
      'update': update, 
    };
  }
}

class Category {
  String? name;

  Category({this.name});

  Category.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}