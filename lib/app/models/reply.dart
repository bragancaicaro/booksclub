class Reply {
  final String id;
  final String userName;
    final String user;
    final bool isMe;
  final String dateCreated;
  final String? parentComment;
  final String message;

  Reply({
    required this.id,
    required this.userName,
    required this.user,
    required this.isMe,
    required this.dateCreated,
    required this.parentComment,
    required this.message,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      id: json['id'],
      userName: json['user_name'],
      user: json['user'],
      isMe: json['is_me'],
      dateCreated: json['date_created'],
      parentComment: json['parent_comment'],
      message: json['message'],
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_name': userName,
      'user': user,
      'is_me': isMe,
      'date_created': dateCreated,
      'parent_comment': parentComment,
      'message': message,
    };
  }
  
}