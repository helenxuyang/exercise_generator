import 'package:flutter/material.dart';

Widget targetChips = Chips(['💪 arms', '🦵 legs', '🆎 core', '❤ cardio']);
Widget equipmentChips = Chips(['🔔 dumbbells', '🍫 barbells']);

class Chips extends StatefulWidget {
  Chips(this.names);
  final List<String> names;
  _ChipsState createState() => _ChipsState();
}

class _ChipsState extends State<Chips> {
  List<bool> selected;

  @override
  void initState() {
    super.initState();
    selected = [for (int i = 0; i < widget.names.length; i++) false];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 8,
        runSpacing: 4,
        children: widget.names.map((target) {
          int index = widget.names.indexOf(target);
          return FilterChip(
            selectedColor: Colors.blue,
            padding: EdgeInsets.all(8),
            labelStyle: TextStyle(fontSize: 16, color: selected[index] ? Colors.white : Colors.grey[800]),
            showCheckmark: false,
            label: Text(target),
            selected: selected[index],
            onSelected: (value) {
              setState(() {
                selected[index] = value;
              });
            },
          );
        }).toList()
    );
  }
}