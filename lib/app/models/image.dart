class Image {
  final String id;
  final String imageUrl;
  final String userName;

  Image({
    required this.id,
    required this.imageUrl,
    required this.userName,
  });

  factory Image.fromJson(Map<String, dynamic> json) {
    return Image(
      id: json['id'],
      imageUrl: json['image'],
      userName: json['user_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image': imageUrl,
      'user_name':userName,
    };
  }
}