class Api {
  // BASE
  static const String baseUrl = 'https://booksclubapp.uc.r.appspot.com';
  static const String baseApiV2Url = 'https://booksclubapp.uc.r.appspot.com/api/v2';
  
  // BASE TO SHARE
  static const String baseUrlShareBook = 'https://booksclub.app/book/';
  static const String baseUrlShareTalk = 'https://booksclub.app/talk/';

  // BASE ACCOUNTS & BOOKS
  static const String baseUrlAccounts = '$baseApiV2Url/accounts'; 
  static const String baseUrlBooks = '$baseApiV2Url/books'; 
  
  // WITHOUT AUTHORIZE
  static const String login = '$baseUrl/token-auth/';
  static const String createAccount = '$baseUrl/registration/';

  // ACCOUNTS PREFIX
  static const String userData = '$baseUrlAccounts/user/';
  static const String userUpdate = '$baseUrlAccounts/update/';
  static const String userUpdatePassword = '$baseUrlAccounts/update/password/';
  static const String recoverAccount = '$baseUrlAccounts/password/recover/';
  static const String recoverAccountConfirm = '$baseUrlAccounts/password/recover/confirm/';
  static const String block = '$baseUrlAccounts/block/create/';

  // RETURN MY ACCOUNT
  static const String mBooks = '$baseUrlBooks/user/book/';
  static const String mTalks = '$baseUrlBooks/user/talk/';
  static const String mImages = '$baseUrlBooks/user/image/';

  // BASE INTERACTIONS
  static const String mRead = '$baseUrlBooks/user/read/';
  static const String mFollow = '$baseUrlBooks/user/follow/';
  static const String mSave = '$baseUrlBooks/user/save/';
  static const String mLike = '$baseUrlBooks/user/like/';
  
  // BOOKS PREFIX
  static const String book = '$baseUrlBooks/book/';
  static const String talk = '$baseUrlBooks/talk/';
  static const String comment = '$baseUrlBooks/comment/';
  static const String reply = '$baseUrlBooks/reply/';
  static const String follow = '$baseUrlBooks/follow/';
  static const String read = '$baseUrlBooks/read/';
  static const String save = '$baseUrlBooks/save/';
  static const String like = '$baseUrlBooks/like/';
  static const String image = '$baseUrlBooks/image/';
  static const String talkComments = '$baseUrlBooks/comment/?talk=';
  static const String replyComments = '$baseUrlBooks/reply/?parent_comment=';
  static const String images = '$baseUrlBooks/media/book/images/';
  static const String update = '$baseUrlBooks/update/';
  static const String updatesBook = '$baseUrlBooks/updates/book/';
  static const String updatesTalk = '$baseUrlBooks/updates/talk/';
  static const String recommendations = '$baseUrlBooks/recommendations/';
  static const String returnImages = 'https://storage.cloud.google.com/booksclub_booksclub_bucket/media/book/images/';
  static const String returnAudioTalk = '$baseUrlBooks/media/talk/audio/';
  static const String returnTalkByBook = '$baseUrlBooks/talk/?book=';
  static const String returnTalksLikeByBook = '$baseUrlBooks/talk-like/?book=';
  static const String returnTalksCommentByBook = '$baseUrlBooks/talk-comment/?book=';
  static const String returnTalks = '$baseUrlBooks/talks/';

  static const String returnTalksRecommendation = '$baseUrlBooks/talk-recommentations/';
  static const String imagesBook = '$baseUrlBooks/image/?book=';

  static const String rating = '$baseUrlBooks/rating/';

  static const String report = '$baseUrlBooks/create/report/';
  


}
