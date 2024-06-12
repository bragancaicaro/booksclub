class Update {
  final String id;
	final String typeUpdate; 
	final String? book; 
	final String? bookTitle; 
  final String? talk;
	final String? talkSubject; 
  final int numberUpdates;
	final String dateCreated; 

  Update({
    required this.id,
    required this.typeUpdate,
    required this.book,
    required this.bookTitle,
    required this.talk,
    required this.talkSubject,
    required this.numberUpdates,
    required this.dateCreated
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update( 
      id: json['id'],
      typeUpdate: json['type_update'],
      book: json['book'],
      bookTitle: json['book_title'],
      talk: json['talk'],
      talkSubject: json['talk_subject'],
      numberUpdates: json['n_update'],
      dateCreated: json['date_created']
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
			'type_update': typeUpdate,
			'book': book,
			'book_title': bookTitle, 
			'talk': talk, 
			'talk_subject': talkSubject, 
      'n_update': numberUpdates,
			'date_created': dateCreated, 
    };
  }
  
}