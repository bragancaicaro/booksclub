class Interactions {
  final String id;
  final String user;
  final String? book;
  final String? bookTitle;
  final String? talk;
  final String? talkSubject;
  final String dateCreated;

  Interactions({
    required this.id,
    required this.user,
    required this.book,
    required this.bookTitle,
    required this.talk,
    required this.talkSubject,
    required this.dateCreated,
  });

  factory Interactions.fromJson(Map<String, dynamic> json) {
    return Interactions(
      id: json['id'],
      user: json['user'],
      book: json['book'],
      bookTitle: json['book_title'],
      talk: json['talk'],
      talkSubject: json['talk_subject'],
      dateCreated: json['date_created'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'book': book,
      'book_title': bookTitle,
      'talk': talk,
      'talk_subject': talkSubject,
      'date_created': dateCreated,
    };
  }
  
}