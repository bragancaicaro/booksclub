class User {
  final String id;
  final String name;
  final String email;
  final int following;
  final int read;
  final int saved;
  final int liked;
  final int numberBooks;
  final int numberTalks;
  final int numberImages;
  
  User({
    this.id = '',
    this.name = '',
    this.email = '',
    this.following = 0,
    this.read = 0,
    this.saved = 0,
    this.liked = 0,
    this.numberBooks = 0,
    this.numberTalks = 0,
    this.numberImages = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User( 
      id: json['id'],
      name: json['name'],
      email: json['email'],
      following: json['following'],
      read: json['read'],
      saved: json['saved'],
      liked: json['liked'],
      numberBooks: json['n_books'],
      numberTalks: json['n_talks'],
      numberImages: json['n_images'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
			'name': name,
			'email': email, 
			'following': following, 
			'read': read,
			'saved': saved, 
			'liked': liked,
			'n_books': numberBooks,
			'n_talks': numberTalks, 
      'n_images': numberImages,
    };
  }

}