import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HighlightCalendar extends StatefulWidget {
  HighlightCalendar(this.daysExercised);
  final List<DateTime> daysExercised;
  @override
  State<StatefulWidget> createState() => _HighlightCalendarState();
}

class _HighlightCalendarState extends State<HighlightCalendar> {
  DateTime now = DateTime.now();
  int year;
  int month;

  @override
  void initState() {
    super.initState();
    year = now.year;
    month = now.month;
  }

  @override
  Widget build(BuildContext context) {
    bool isLeapYear = year % 4 == 0 || (year % 100 == 0 && year % 400 == 0);
    Map<int, int> daysInMonth = {
      1: 31,
      2: isLeapYear ? 29 : 28,
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31
    };

    int firstWeekday = DateTime(year, month, 1).weekday;
    int daysBefore = firstWeekday == DateTime.sunday ? 0 : firstWeekday;
    int lastWeekday = DateTime(year, month, daysInMonth[month]).weekday;
    int daysAfter = lastWeekday == DateTime.sunday ? 6 : 6 - lastWeekday;

    bool listHasDate(List<DateTime> list, DateTime date) {
      for (DateTime d in list) {
        if (d.isAtSameMomentAs(date)) return true;
      }
      return false;
    }

    return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 40),
                    onPressed: () {
                      if (month == 1) {
                        setState(() {
                          month = 12;
                          year--;
                        });
                      }
                      else {
                        setState(() {
                          month--;
                        });
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
                    child: Text(DateFormat.yMMM().format(DateTime(year, month, 1)), style: Theme.of(context).textTheme.headline1),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 40),
                    onPressed: (month == now.month && year == now.year) ? null : () {
                      if (month == 12) {
                        setState(() {
                          month = 1;
                          year++;
                        });
                      }
                      else {
                        setState(() {
                          month++;
                        });
                      }
                    },
                  ),
                ]
            ),
          ),
          GridView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 16, right: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'].map((str) {
                return Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(str)
                );
              }).toList()
          ),
          SizedBox(height: 4),
          Expanded(
              child: GridView.builder(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                  itemCount: daysInMonth[month] + daysBefore + daysAfter,
                  itemBuilder: (context, index) {
                    int day = index + 1 - daysBefore;
                    //month before
                    if (index < daysBefore) {
                      int prevMonth = month == 1 ? 12 : month - 1;
                      int newYear = prevMonth == 12 ? year - 1 : year;
                      return DayBox(DateTime(newYear, prevMonth, daysInMonth[prevMonth] + day), true);
                    }
                    //month after
                    if (index >= daysInMonth[month] + daysBefore) {
                      int nextMonth = month == 12 ? 1 : month + 1;
                      int newYear = nextMonth == 1 ? year + 1 : year;
                      return DayBox(DateTime(newYear, nextMonth, day - daysInMonth[nextMonth]), true);
                    }
                    DateTime today = DateTime(year, month, day);
                    //days after today
                    if (year == now.year && month == now.month && day > now.day) {
                      return DayBox(today, true);
                    }
                    //exercised
                    if (listHasDate(widget.daysExercised, today)) {
                      return DayBox(today, false, initExercised: true);
                    }
                    //didn't exercise
                    else {
                      return DayBox(today, false, initExercised: false);
                    }
                  }
              )
          ),
        ]
    );
  }
}

class DayBox extends StatefulWidget {
  final DateTime date;
  final bool greyedOut;
  final bool initExercised;

  DayBox(this.date, this.greyedOut, {this.initExercised});
  @override
  _DayBoxState createState() => _DayBoxState();
}

class _DayBoxState extends State<DayBox> {
  bool exercised = false;

  @override
  void didUpdateWidget(DayBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date != oldWidget.date) {
      if (widget.initExercised != null) exercised = widget.initExercised;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initExercised != null) exercised = widget.initExercised;
  }

  void removeHistory(DateTime date) async {
    QuerySnapshot query = await Firestore.instance.collection('history')
        .where('year', isEqualTo: date.year)
        .where('month', isEqualTo: date.month)
        .where('day', isEqualTo: date.day)
        .getDocuments();
    List<DocumentSnapshot> docs = query.documents;
    docs.forEach((doc) async {
      await Firestore.instance.runTransaction((transaction) async {
        await transaction.delete(doc.reference);
      });
    });
  }

  void addHistory(DateTime date) async {
    await Firestore.instance.collection('history').add({'year': date.year, 'month': date.month, 'day': date.day});
  }

  Widget build(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: widget.greyedOut ? Colors.grey[300] : exercised ? Colors.green : Colors.grey[600]
          ),
          child: Center(
              child: Text(widget.date.day.toString(), style: TextStyle(color: Colors.grey[200]))
          ),
        ),
      ),
      onLongPress: () {
        if (!widget.greyedOut) {
          if (exercised) removeHistory(widget.date);
          else addHistory(widget.date);
          setState(() {
            exercised = !exercised;
          });
        }
      },
    );
  }
}