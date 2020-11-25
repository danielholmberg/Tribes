part of created_posts_view;

class _CreatedPostsViewMobile extends ViewModelWidget<CreatedPostsViewModel> {
  @override
  Widget build(BuildContext context, CreatedPostsViewModel model) {
    return ScrollConfiguration(
      behavior: CustomScrollBehavior(),
      child: GridView.builder(
        itemCount: model.createdPostsCount,
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 80.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.0,
          crossAxisCount: 3,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return StreamBuilder<Post>(
            stream: model.getCreatedPost(index),
            builder: (context, snapshot) {
              if(snapshot.hasData) {
                Post createdPost = snapshot.data;
                return PostItemCompact(post: createdPost, user: model.user, viewOnly: model.viewOnly);
              } else if(snapshot.hasError) {
                print('Error retrieving CreatedPost (${model.user.createdPosts[index]}): ${snapshot.error.toString()}');
                return Container(padding: EdgeInsets.all(16), child: Center(child: Icon(FontAwesomeIcons.exclamationCircle)));
              } else {
                return Loading();
              }
            }
          );
        }, 
      ),
    );
  }
}