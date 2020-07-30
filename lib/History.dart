import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Calendar.dart';

class HistoryPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('history').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ' + snapshot.error);
          }
          else if (!snapshot.hasData) {
            return Center(
                child: CircularProgressIndicator()
            );
          }
          else {
            List<DateTime> daysExercised = [];
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot doc = snapshot.data.documents[i];
              daysExercised.add(DateTime(doc['year'], doc['month'], doc['day']));
            }
            return HighlightCalendar(daysExercised);
          }
        }
    );
  }
}