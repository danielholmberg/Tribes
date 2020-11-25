import 'package:stacked/stacked.dart';
import 'package:tribes/locator.dart';
import 'package:tribes/models/post_model.dart';
import 'package:tribes/services/firebase/auth_service.dart';
import 'package:tribes/services/firebase/database_service.dart';

class LikedPostsViewModel extends ReactiveViewModel {
  final AuthService _authService = locator<AuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  
  List<String> get likedPostsList => _databaseService.currentUserData.likedPosts.reversed.toList();
  int get likedPostsCount => likedPostsList.length;

  Stream<Post> getPostStream(int index) => _databaseService.post(_databaseService.currentUserData.id, likedPostsList[index]);

  @override
  List<ReactiveServiceMixin> get reactiveServices => [_databaseService];
  }