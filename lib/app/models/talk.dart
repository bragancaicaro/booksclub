class Talk {
  final String id;
	final String book; 
	final String bookTitle; 
	final String user; 
	final String userName; 
	final String subject; 
	final String typeTalk; 
	final String? audioFile; 
  final String? audioFileName;
	final bool liked;
	final dynamic likeId; 
	final int likeCount; 
	final dynamic update;
	final int commentCount;
	final String dateCreated; 

  Talk({
    required this.id,
    required this.book,
    required this.bookTitle,
    required this.user,
    required this.userName,
    required this.subject,
    required this.typeTalk,
    required this.audioFile,
    required this.audioFileName,
    required this.liked,
    required this.likeId,
    required this.likeCount,
    required this.update,
    required this.commentCount,
    required this.dateCreated,
  });

  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk( 
      id: json['id'],
      book: json['book'],
      bookTitle: json['book_title'],
      user: json['user'],
      userName: json['user_name'],
      subject: json['subject'],
      typeTalk: json['type'],
      audioFile: json['audio_file'],
      audioFileName: json['audio_file_name'],
      liked: json['liked'],
      likeId: json['like_id'],
      likeCount: json['like_count'],
      update: json['update'],
      commentCount: json['comment_count'],
      dateCreated: json['date_created'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
			'book': book,
			'book_title': bookTitle, 
			'user': user, 
			'user_name': userName,
			'subject': subject, 
			'type_talk': typeTalk,
			'audio_file': audioFile, 
      'audio_file_name': audioFileName,
			'date_created': dateCreated, 
			'liked': liked,
			'like_id': likeId, 
			'like_count': likeCount, 
			'update': update,
			'comment_count': commentCount,
    };
  }
  
}