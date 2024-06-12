class Comment {
  final String id;
  final String userName;
  final String user;
  final bool isMe;
  final String dateCreated;
  final String? parentComment;
  final String message;
  final int replyCount;
  bool showTextReplies = true;
  bool showReplies = false;
  bool viewMoreReplies = false;

  Comment({
    required this.id,
    required this.userName,
    required this.user,
    required this.isMe,
    required this.dateCreated,
    required this.parentComment,
    required this.replyCount,
    required this.message,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      userName: json['user_name'],
      user: json['user'],
      isMe: json['is_me'],
      dateCreated: json['date_created'],
      parentComment: json['parent_comment'],
      replyCount: json['reply_count'],
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
      'reply_count': replyCount,
      'message': message,
    };
  }
  
}