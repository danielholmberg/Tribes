import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:tribes/screens/base/tribes/widgets/CustomImage.dart';
import 'package:tribes/shared/constants.dart' as Constants;

class FullscreenCarousel extends StatefulWidget {
  final List<String> images;
  final Color color;
  final int initialIndex;
  final Function onPageChange;
  final bool showOverlayWidgets;
  FullscreenCarousel({
    @required this.images,
    this.color = Constants.primaryColor,
    this.initialIndex = 0,
    this.onPageChange,
    this.showOverlayWidgets = true,
  });

  @override
  _FullscreenCarouselState createState() => _FullscreenCarouselState();
}

class _FullscreenCarouselState extends State<FullscreenCarousel> with TickerProviderStateMixin {

  int _current;

  @override
  void initState() {
    _current = widget.initialIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    bool showIndicator = widget.images.length > 1;

    _buildImageIndicator() {
      return Container(
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20)
        ),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? widget.color : widget.color.withOpacity(0.6),
              border: Border.all(color: _current == index ? Colors.white.withOpacity(0.8) : widget.color.withOpacity(0.6), width: 2.0),
            ),
            child: Text(
              '${index+1}',
              style: TextStyle(
                color: _current == index ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                fontFamily: 'TribesRounded',
              ),
            ),
          )),
        ),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[

        // Images
        Positioned.fill(
          child: CarouselSlider.builder(
            height: MediaQuery.of(context).size.height,
            initialPage: widget.initialIndex,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return CustomImage(
                imageURL: widget.images[index],
                color: widget.color,
                fullscreen: true,
              );
            },
            viewportFraction: 1.0,
            reverse: false,
            autoPlay: false,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
              if(widget.onPageChange != null) widget.onPageChange(index);
            },
          ),
        ),

        Positioned(
          top: 58.0,
          child: Visibility(
            visible: showIndicator,
            child: IgnorePointer(
              ignoring: !widget.showOverlayWidgets,
              child: AnimatedOpacity(
                opacity: widget.showOverlayWidgets ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: _buildImageIndicator(),
              ),
            ),
          ),
        )
        
      ],
    );
  }
}