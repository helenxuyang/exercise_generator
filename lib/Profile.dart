import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> goals = [];
    return Column(
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headline1),
        Text('Exercise goals'),
        ListView(
          shrinkWrap: true,
          children: goals.map((str) => Text(str)).toList()
        )
      ]
    );
  }
}