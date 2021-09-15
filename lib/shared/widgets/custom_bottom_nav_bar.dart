import 'package:flutter/material.dart';
import 'package:tribes/shared/widgets/custom_awesome_icon.dart';
import 'package:tribes/shared/widgets/custom_nav_bar_item.dart';

class CustomBottomNavBar extends StatefulWidget {
  final List<CustomNavBarItem> items;
  final int currentIndex;
  final int Function(int val) onTap;
  final Color selectedBackgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final Color backgroundColor;
  final double fontSize;
  final double iconSize;

  const CustomBottomNavBar(
      {Key key,
      @required this.items,
      @required this.currentIndex,
      @required this.onTap,
      this.backgroundColor = Colors.black,
      this.selectedBackgroundColor = Colors.white,
      this.selectedItemColor = Colors.black,
      this.iconSize = 24.0,
      this.fontSize = 11.0,
      this.unselectedItemColor = Colors.white})
      : assert(items.length > 1),
        assert(items.length <= 5),
        assert(currentIndex <= items.length),
        super(key: key);

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  List<CustomNavBarItem> get items => widget.items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 5,
            spreadRadius: 1
          )
        ],
        color: widget.backgroundColor,
      ),
      width: double.infinity,
      child: BottomAppBar(
        color: Colors.transparent,
        elevation: 0.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              mainAxisSize: MainAxisSize.max,
              children: items.map((item) {
                int index = items.indexOf(item);
                double width =  widget.currentIndex == index
                      ? (MediaQuery.of(context).size.width / items.length) + 20
                      : 50;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,
                  width: width,
                  decoration: BoxDecoration(
                      color: widget.currentIndex == index
                          ? widget.selectedBackgroundColor
                          : widget.backgroundColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: InkWell(
                    onTap: () {
                      this.widget.onTap(index);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        item.avatar != null ? item.avatar : CustomAwesomeIcon(
                          icon: item.icon,
                          color: widget.currentIndex == index
                              ? widget.selectedItemColor
                              : widget.unselectedItemColor,
                          size: widget.iconSize,
                        ),
                        Visibility(
                          visible: widget.currentIndex == index,
                          child: Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                '${item.title}',
                                maxLines: 1,
                                style: TextStyle(
                                  color: widget.currentIndex == index
                                      ? widget.selectedItemColor
                                      : widget.unselectedItemColor,
                                  fontSize: widget.fontSize,
                                  fontFamily: 'TribesRounded',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
