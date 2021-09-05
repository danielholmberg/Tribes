part of edit_post_view;

class _EditPostViewMobile extends ViewModelWidget<EditPostViewModel> {
  @override
  Widget build(BuildContext context, EditPostViewModel model) {
    final ThemeData themeData = Theme.of(context);

    _showDiscardDialog() {
      return showDialog(
        context: context,
        builder: (context) => DiscardChangesDialog(
          color: model.tribeColor,
        ),
      );
    }

    _buildAppBar() {
      return AppBar(
        backgroundColor: themeData.backgroundColor,
        elevation: 0.0,
        titleSpacing: 0,
        iconTheme: IconThemeData(
          color: model.tribeColor,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              'Editing',
              style: TextStyle(
                fontFamily: 'TribesRounded',
                fontWeight: FontWeight.bold,
                color: model.tribeColor,
              ),
            ),
            SizedBox(width: Constants.defaultPadding),
            Visibility(
              visible: model.edited,
              child: Text(
                '| edited',
                style: TextStyle(
                  fontFamily: 'TribesRounded',
                  fontStyle: FontStyle.normal,
                  fontSize: 12,
                  color: model.tribeColor,
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.times),
          color: model.tribeColor,
          onPressed: () {
            model.edited ? _showDiscardDialog() : model.back();
          },
        ),
        actions: <Widget>[
          IconButton(
            splashColor: Colors.transparent,
            color: themeData.backgroundColor,
            icon: CustomAwesomeIcon(
              icon: FontAwesomeIcons.solidTrashAlt,
              color: model.tribeColor,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        Constants.dialogCornerRadius,
                      ),
                    ),
                  ),
                  backgroundColor: Constants.profileSettingsBackgroundColor,
                  title: Text(
                    'Are your sure you want to delete this post?',
                    style: TextStyle(
                      fontFamily: 'TribesRounded',
                      fontWeight: Constants.defaultDialogTitleFontWeight,
                      fontSize: Constants.defaultDialogTitleFontSize,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        'No',
                        style: TextStyle(
                          color: model.tribeColor,
                          fontFamily: 'TribesRounded',
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'TribesRounded',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: model.onDeletePostConfirm,
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(width: 4.0)
        ],
      );
    }

    _buildNewImageIcon() {
      return Center(
        child: CustomAwesomeIcon(
          icon: Icons.add_photo_alternate_rounded,
          size: 30,
          color: model.tribeColor.withOpacity(
            model.photoButtonIsDisabled ? 0.4 : 1.0,
          ),
        ),
      );
    }

    List<Widget> _buildImages(int length, bool isNewImage) {
      return List.generate(length, (index) {
        int _imageNumber = index + 1 + (isNewImage ? model.oldImagesCount : 0);

        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Stack(
              children: <Widget>[
                isNewImage
                    ? AssetThumb(
                        asset: model.newImages[index],
                        width: 300,
                        height: 300,
                      )
                    : CustomImage(
                        imageURL: model.oldImages[index],
                        color: model.tribeColor,
                        width: 300,
                        height: 300,
                        margin: EdgeInsets.zero,
                      ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Visibility(
                    visible: model.imagesCount > 1,
                    child: Container(
                      height: 24,
                      width: 24,
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
                      onTap: () => model.onRemoveImage(index, isNewImage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    }

    _buildGridView() {
      List<Widget> children = [];

      if (model.oldImagesCount > 0) {
        children += _buildImages(model.oldImagesCount, false);
      }

      if (model.newImagesCount > 0) {
        children += _buildImages(model.newImagesCount, true);
      }

      return GridView.count(
        crossAxisCount: 3,
        padding: Constants.imageGridViewPadding,
        shrinkWrap: true,
        crossAxisSpacing: Constants.imageGridViewCrossAxisSpacing,
        mainAxisSpacing: Constants.imageGridViewMainAxisSpacing,
        children: <Widget>[
              GestureDetector(
                onTap: model.photoButtonIsDisabled ? null : model.onNewImage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      width: 2.0,
                      color: model.tribeColor.withOpacity(
                        model.photoButtonIsDisabled ? 0.4 : 1.0,
                      ),
                    ),
                  ),
                  child: _buildNewImageIcon(),
                ),
              ),
            ] +
            children,
      );
    }

    _buildStepIndicator(int number, {bool completed = false}) {
      return GestureDetector(
        onTap: () async => await model.onStepIndicatorPress(number),
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

    _buildSaveButton() {
      return Visibility(
        visible: model.completed && model.edited,
        child: CustomButton(
          height: 60.0,
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.all(16.0),
          color: model.tribeColor,
          icon: FontAwesomeIcons.check,
          label: Text(
            'Save',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'TribesRounded',
            ),
          ),
          labelColor: Colors.white,
          onPressed: model.edited ? model.onSavePost : null,
        ),
      );
    }

    return WillPopScope(
      onWillPop: () => model.edited ? _showDiscardDialog() : Future.value(true),
      child: Container(
        color: model.tribeColor,
        child: SafeArea(
          bottom: false,
          child: model.isBusy
              ? Loading(color: model.tribeColor)
              : Scaffold(
                  backgroundColor: themeData.backgroundColor,
                  appBar: _buildAppBar(),
                  body: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned.fill(
                        child: ScrollConfiguration(
                          behavior: CustomScrollBehavior(),
                          child: ListView(
                            padding: EdgeInsets.only(bottom: 86.0, right: 16.0),
                            shrinkWrap: true,
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
                                              initialValue: model.title,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              style:
                                                  themeData.textTheme.headline6,
                                              cursorColor: model.tribeColor,
                                              decoration: Decorations.postInput
                                                  .copyWith(
                                                hintText: 'Title',
                                              ),
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
                                              horizontal: 16.0,
                                            ),
                                            child: _buildStepIndicator(
                                              2,
                                              completed: model.step2Completed,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextFormField(
                                              focusNode: model.contentFocus,
                                              cursorRadius: Radius.circular(
                                                1000,
                                              ),
                                              cursorWidth: 2,
                                              initialValue: model.content,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              style:
                                                  themeData.textTheme.bodyText2,
                                              cursorColor: model.tribeColor,
                                              keyboardType:
                                                  TextInputType.multiline,
                                              maxLines: null,
                                              decoration: Decorations.postInput
                                                  .copyWith(
                                                hintText: 'Content',
                                              ),
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
                                  Expanded(child: _buildGridView())
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
                        child: _buildSaveButton(),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
