class Post {

  final String id;
  final String userID;
  final String tribeID;
  final String title;
  final String content;
  final List<String> attachments = new List<String>();

  Post({ this.id, this.userID, this.tribeID, this.title, this.content });

}