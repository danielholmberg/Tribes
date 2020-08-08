part of chat_view;

class _ChatViewMobile extends StatelessWidget {
  final ChatViewModel viewModel;
  _ChatViewMobile(this.viewModel);

  @override
  Widget build(BuildContext context) {
    _categorySelector() {
      return Container(
        height: 60.0,
        color: DynamicTheme.of(context).data.primaryColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: viewModel.tabs.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Center(
              child: GestureDetector(
                onTap: () => viewModel.setCurrentTab(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    viewModel.tabs[index],
                    style: TextStyle(
                      color: index == viewModel.currentTab ? Colors.white : Colors.white60,
                      fontFamily: 'TribesRounded',
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    _buildAppBar() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.search),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: () => Fluttertoast.showToast(
                msg: 'Coming soon!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              ),
            ),
            _categorySelector(),
            IconButton(
              icon: Icon(FontAwesomeIcons.commentMedical),
              iconSize: Constants.defaultIconSize,
              color: Colors.white,
              onPressed: () => Navigator.push(context, 
                CustomPageTransition(
                  type: CustomPageTransitionType.newMessage, 
                  duration: Constants.pageTransition600, 
                  child: NewChatView(currentUserID: viewModel.currentUserData.id),
                )
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: DynamicTheme.of(context).data.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: DynamicTheme.of(context).data.primaryColor,
          body: Column(
            children: <Widget>[
              _buildAppBar(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: DynamicTheme.of(context).data.backgroundColor,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ]
                  ),
                  child: viewModel.currentTab == 0 ? PrivateMessagesView() : TribeMessagesView(), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}