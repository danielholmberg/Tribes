import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';

class CreatedPostsViewModel extends ReactiveViewModel {
  final MyUser user;
  final bool viewOnly;
  CreatedPostsViewModel({this.user, this.viewOnly});

  final DatabaseService _databaseService = locator<DatabaseService>();

  List<String> get createdPostsList => user.createdPosts.reversed.toList();
  int get createdPostsCount => createdPostsList.length;

  Stream<Post> getCreatedPost(int index) => _databaseService.post(user.id, createdPostsList[index]);

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
}