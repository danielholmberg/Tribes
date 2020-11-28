library map_view;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';
import 'package:tribes/core/map/map_view_model.dart';
import 'package:tribes/models/tribe_model.dart';
import 'package:tribes/models/user_model.dart';
import 'package:tribes/services/firebase/database_service.dart';
import 'package:tribes/shared/constants.dart' as Constants;
import 'package:tribes/shared/widgets/custom_scroll_behavior.dart';
import 'package:tribes/shared/widgets/loading.dart';
import 'package:tribes/shared/widgets/user_avatar.dart';

part 'map_view_[mobile].dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<MapViewModel>.reactive(
      viewModelBuilder: () => MapViewModel(),
      onModelReady: (model) => model.initState(isMounted: this.mounted),
      builder: (context, model, child) {
        return ScreenTypeLayout.builder(
          mobile: (context) => _MapViewMobile(),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
