import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatefulWidget {
  @override
  _CategorySelectorState createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {

  int _currentCategory = 0;
  final List<String> categories = ['Messages', 'Online', 'Groups'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.0,
      color: DynamicTheme.of(context).data.primaryColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => setState(() => _currentCategory = index),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: index == _currentCategory ? Colors.white : Colors.white60,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}