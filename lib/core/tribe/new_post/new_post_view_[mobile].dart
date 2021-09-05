part of new_post_view;

class _NewPostViewMobile extends ViewModelWidget<NewPostViewModel> {
  @override
  Widget build(BuildContext context, NewPostViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _buildAppBar() {
      return AppBar(
        elevation: 0.0,
        backgroundColor: themeData.backgroundColor,
        leading: IconButton(
          icon: CustomAwesomeIcon(
            icon: FontAwesomeIcons.times,
            color: model.tribeColor,
          ),
          onPressed: model.onExit,
        ),
        title: Text(
          'New post',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: themeData.textTheme.headline6
              .copyWith(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[],
      );
    }

    _buildNewImageIcon() {
      return Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomAwesomeIcon(
            icon: FontAwesomeIcons.image,
            size: 30,
            color: model.tribeColor.withOpacity(
              model.photoButtonIsDisabled ? 0.4 : 1.0,
            ),
          ),
          Positioned(
            right: 22,
            bottom: 25,
            child: Container(
              child: CustomAwesomeIcon(
                icon: FontAwesomeIcons.plus,
                size: 14,
                color: model.tribeColor.withOpacity(
                  model.photoButtonIsDisabled ? 0.4 : 1.0,
                ),
                strokeWidth: 2.0,
              ),
            ),
          ),
        ],
      );
    }

    _buildGridView() {
      return GridView.count(
        crossAxisCount: 3,
        padding: Constants.imageGridViewPadding,
        shrinkWrap: true,
        crossAxisSpacing: Constants.imageGridViewCrossAxisSpacing,
        mainAxisSpacing: Constants.imageGridViewMainAxisSpacing,
        children: <Widget>[
              GestureDetector(
                onTap: model.photoButtonIsDisabled
                    ? null
                    : () async => await model.loadAssets(),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      width: 2.0,
                      color: model.tribeColor
                          .withOpacity(model.photoButtonIsDisabled ? 0.4 : 1.0),
                    ),
                  ),
                  child: _buildNewImageIcon(),
                ),
              ),
            ] +
            List.generate(
              model.imagesCount,
              (index) {
                int _imageNumber = index + 1;
                Asset asset = model.images[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      children: <Widget>[
                        AssetThumb(
                          asset: asset,
                          width: 300,
                          height: 300,
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Visibility(
                            visible: model.imagesCount > 1,
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: model.tribeColor,
                                borderRadius: BorderRadius.circular(1000),
                              ),
                              child: Center(
                                child: Text(
                                  '$_imageNumber',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    fontFamily: 'TribesRounded',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 1.0),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: GestureDetector(
                              child: CustomAwesomeIcon(
                                icon: FontAwesomeIcons.timesCircle,
                              ),
                              onTap: () => model.onRemoveImage(index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      );
    }

    _buildPublishButton() {
      return Visibility(
        visible: model.completedAllSteps,
        child: CustomButton(
          icon: FontAwesomeIcons.check,
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          label: Text(
            'Publish',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          color: Colors.green,
          iconColor: Colors.white,
          onPressed: model.onPublishPost,
        ),
      );
    }

    _buildStepIndicator(int number, {bool completed = false}) {
      return GestureDetector(
        onTap: () => model.onStepIndicatorPress(number),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: completed
                ? model.tribeColor.withOpacity(0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(1000),
            border: Border.all(
              color: model.tribeColor,
              width: 2.0,
            ),
          ),
          child: Center(
            child: completed
                ? CustomAwesomeIcon(
                    icon: FontAwesomeIcons.check,
                    size: 10,
                    color: Colors.white,
                  )
                : Text(
                    '$number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: model.tribeColor,
                      fontFamily: 'TribesRounded',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: model.onWillPop,
      child: Container(
        color: model.tribeColor,
        child: SafeArea(
          bottom: false,
          child: model.isBusy
              ? Loading(color: model.tribeColor)
              : Scaffold(
                  backgroundColor: themeData.backgroundColor,
                  extendBody: true,
                  appBar: _buildAppBar(),
                  body: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned.fill(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(bottom: 76.0, right: 16.0),
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topLeft,
                                child: Form(
                                  key: model.formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                              horizontal: 16.0,
                                            ),
                                            child: _buildStepIndicator(
                                              1,
                                              completed: model.step1Completed,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              focusNode: model.titleFocus,
                                              cursorRadius: Radius.circular(
                                                1000,
                                              ),
                                              cursorWidth: 4,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              style:
                                                  themeData.textTheme.headline6,
                                              cursorColor: model.tribeColor,
                                              decoration: Decorations.postInput
                                                  .copyWith(hintText: 'Title'),
                                              onChanged: model.onTitleChanged,
                                              onFieldSubmitted:
                                                  model.onTitleSubmitted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: _buildStepIndicator(
                                              2,
                                              completed: model.step2Completed,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              focusNode: model.contentFocus,
                                              cursorRadius:
                                                  Radius.circular(1000),
                                              cursorWidth: 2,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              style:
                                                  themeData.textTheme.bodyText2,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              textAlign: TextAlign.start,
                                              textAlignVertical:
                                                  TextAlignVertical.top,
                                              cursorColor: model.tribeColor,
                                              decoration: Decorations.postInput
                                                  .copyWith(
                                                      hintText: 'Content'),
                                              onChanged: model.onContentChanged,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                      horizontal: 16.0,
                                    ),
                                    child: _buildStepIndicator(
                                      3,
                                      completed: model.step3Completed,
                                    ),
                                  ),
                                  Expanded(child: _buildGridView()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 8.0 : 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: _buildPublishButton(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
