import 'dart:async';
import 'package:quiver/async.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Exercise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StartWidget extends StatelessWidget {
  final List<String> buttonTexts = ['😤😤 Grind 💯💯 NEVER 🙅‍♀🙅‍♂ stops 🛑🛑', '💪😤 HELL yeah 💪😤'];

  @override
  Widget build(BuildContext context) {
    final int randomIndex = Random().nextInt(buttonTexts.length);
    return Column(
        children: [
          SizedBox(height: 150),
          Text('🏋️‍♀️🏋️', style: TextStyle(fontSize: 40)),
          Text('Ready to work out today?', style: TextStyle(fontSize: 24)),
          SizedBox(height: 8),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.blueAccent)
            ),
            padding: EdgeInsets.all(12),
            child: Text(buttonTexts[randomIndex], style: TextStyle(color: Colors.blueAccent)),
            onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSetupPage()));
            },
          ),
        ]
    );
  }
}

class DoneWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(height: 100),
          Text('🎉', style: TextStyle(fontSize: 50)),
          Text('You worked out today!', style: TextStyle(fontSize: 26)),
          SizedBox(height: 50),
          Text('exercise...again??', style: TextStyle(fontSize: 16)),
          Text('haha, jk...', style: TextStyle(fontSize: 16)),
          SizedBox(height: 4),
          FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.blueAccent)
            ),
            padding: EdgeInsets.all(12),
            child: Text('unless? 😳', style: TextStyle(color: Colors.blueAccent)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutSetupPage()));
            },
          ),
        ]
    );
  }
}

class HomeHeader extends StatelessWidget {
  //TODO: get actual name
  final String name = 'Helen';

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 20, top: 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  DateFormat('MMMMEEEEd').format(DateTime.now()),
                  style: Theme.of(context).textTheme.headline1
              ),
              Text('Welcome back, $name!', style: TextStyle(fontSize: 20))
            ]
        )
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<bool> fetchWorkedOutToday() async {
    DateTime today = DateTime.now();
    QuerySnapshot query = await Firestore.instance.collection('history')
        .where('year', isEqualTo: today.year)
        .where('month', isEqualTo: today.month)
        .where('day', isEqualTo: today.day)
        .getDocuments();
    List<DocumentSnapshot> docs = query.documents;
    if (docs.length == 0) {
      return false;
    }
    else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(),
          FutureBuilder(
              future: fetchWorkedOutToday(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error from retrieving workedOut: ' + snapshot.error);
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                else {
                  return snapshot.data ? DoneWidget() : StartWidget();
                }
              }
          )

        ]
    );
  }
}

class Workout {
  Map<Exercise, int> routine = {};
  Workout(List<Exercise> exercises) {
    exercises.forEach((ex) {
      routine[ex] = ex.getRandomNum();
    });
  }

  static Future<List<Exercise>> fetchExercises() async {
    List<Exercise> exercises = [];
    QuerySnapshot query = await Firestore.instance.collection('exercises').getDocuments();
    query.documents.forEach((doc) {
      exercises.add(Exercise(doc['name'], doc['min'], doc['max'], doc['units'], doc['image']));
    });
    return exercises;
  }

  static Future<Workout> buildWorkout(int numExercises) async {
    List<Exercise> allExercises = await fetchExercises();
    List<Exercise> selectedExercises = [];
    for (int i = 0; i < numExercises; i++) {
      if (i + 1 < allExercises.length) {
        int randomIndex = Random().nextInt(allExercises.length - 1);
        selectedExercises.add(allExercises[randomIndex]);
        allExercises.removeAt(randomIndex);
      }
    }
    return Workout(selectedExercises);
  }
}

class WorkoutSetupPage extends StatefulWidget {
  @override
  _WorkoutSetupPage createState() => _WorkoutSetupPage();
}

class _WorkoutSetupPage extends State<WorkoutSetupPage> {
  int numExercises = 1;

  @override
  void initState() {
    super.initState();
  }

  Future<int> fetchTotalNumExercises() async {
    QuerySnapshot query = await Firestore.instance.collection('exercises').getDocuments();
    return query.documents.length;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Workout Options', style: Theme.of(context).textTheme.headline1),
                    ),
                    /*Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Select target areas:', style: Theme.of(context).textTheme.headline2),
                    ),
                    targetChips,
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Select equipment:', style: Theme.of(context).textTheme.headline2),
                    ),
                    equipmentChips,*/
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Select number of exercises:', style: Theme.of(context).textTheme.headline2),
                    ),
                    FutureBuilder(
                        future: fetchTotalNumExercises(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return DropdownButton<int>(
                              value: numExercises,
                              items: [for (int i = 1; i <= snapshot.data; i++) i].map((num) {
                                return DropdownMenuItem<int>(value: num, child: Text(num.toString(), style: TextStyle(fontSize: 18)));
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  numExercises = value;
                                });
                              },
                            );
                          }
                          else return CircularProgressIndicator();
                        }
                    ),
                    SizedBox(height: 16),
                    RaisedButton(
                        child: Text('Start', style: TextStyle(color: Colors.white, fontSize: 20)),
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32))
                        ),
                        color: Colors.blue,
                        onPressed: () async {
                          Workout workout = await Workout.buildWorkout(numExercises);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutPage(workout)));
                        }
                    )
                  ]
              ),
            )
        )
    );
  }
}

class WorkoutPage extends StatefulWidget {
  final Workout workout;
  WorkoutPage(this.workout);

  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  Iterator<MapEntry<Exercise, int>> iterator;
  int numExercisesDone;
  int currentSetNum;
  bool timerStarted = false;
  bool timerDone = false;
  int time = 0;

  @override
  void initState() {
    super.initState();
    iterator = widget.workout.routine.entries.iterator;
    iterator.moveNext();
    numExercisesDone = 0;
    currentSetNum = 1;
  }

  void setExercised() async {
    DateTime today = DateTime.now();
    await Firestore.instance.collection('history').add({'year': today.year, 'month': today.month, 'day': today.day});
  }

  @override
  Widget build(BuildContext context) {
    Exercise currentExercise;
    int currentNum;
    double buttonSize = MediaQuery.of(context).size.width / 8;

    if (iterator.current != null) {
      currentExercise = iterator.current.key;
      currentNum = iterator.current.value;
    }

    return SafeArea(
        child: Scaffold(
            body: (iterator.current == null) ?
            Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text('🎊', style: TextStyle(fontSize: 50)),
                    Text('You finished set $currentSetNum!', style: TextStyle(fontSize: 30)),
                    SizedBox(height: 16),
                    RaisedButton(
                      child: Text('Another set!', style: TextStyle(color: Colors.white, fontSize: 20)),
                      color: Colors.blue,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32))
                      ),
                      onPressed: () {
                        setState(() {
                          iterator = widget.workout.routine.entries.iterator;
                          iterator.moveNext();
                          numExercisesDone = 0;
                          currentSetNum++;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    RaisedButton(
                      child: Text('Finish workout', style: TextStyle(color: Colors.white, fontSize: 20)),
                      color: Colors.blue,
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(32))
                      ),
                      onPressed: () {
                        setExercised();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryPage(widget.workout, currentSetNum)));
                      },
                    ),
                  ],
                )
            ) :
            Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CachedNetworkImage(
                          imageUrl: currentExercise.imageURL,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error)
                      ),
                      SizedBox(height: 16),
                      Text(currentExercise.name.toUpperCase(), style: TextStyle(fontSize: 30)),
                      Text(currentNum.toString() + ' ' + currentExercise.units, style: TextStyle(fontSize: 18)),
                      SizedBox(height: 16),
                      if (currentExercise.units == 'seconds' && !timerStarted)
                        RaisedButton(
                          child: Text('Start timer', style: TextStyle(color: Colors.white, fontSize: 20)),
                          color: Colors.blue,
                          padding: EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(32))
                          ),
                          onPressed: () {
                            time = currentNum;
                            CountdownTimer timer = CountdownTimer(Duration(seconds: currentNum), Duration(seconds: 1));
                            setState(() {
                              timerStarted = true;
                            });
                            StreamSubscription<CountdownTimer> listener = timer.listen((currentTimer) {
                              setState(() {
                                time = currentNum - currentTimer.elapsed.inSeconds;
                              });
                            });
                            listener.onDone(() {
                              listener.cancel();
                              setState(() {
                                timerDone = true;
                              });
                            });
                          },
                        ),
                      if (timerStarted && !timerDone)
                        Text('Time left: $time sec', style: TextStyle(fontSize: 20, color: Colors.blue)),
                      if (currentExercise.units == 'repetitions' || timerDone)
                        RawMaterialButton(
                          child: Icon(Icons.check, color: Colors.white, size: buttonSize),
                          fillColor: Colors.blue,
                          padding: EdgeInsets.all(10),
                          shape: CircleBorder(),
                          onPressed: () {
                            setState(() {
                              iterator.moveNext();
                              numExercisesDone++;
                              timerStarted = false;
                              timerDone = false;
                            });
                          },
                        ),
                      SizedBox(height: 64),
                      Text('Workout progress:'),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: LinearProgressIndicator(value: numExercisesDone / widget.workout.routine.length)
                      ),
                      Text(numExercisesDone.toString() + '/' + widget.workout.routine.length.toString() + ' exercises done of set #$currentSetNum')
                    ]
                )
            )

        )
    );
  }
}

class SummaryPage extends StatelessWidget {
  final Workout workout;
  final int setsCompleted;
  SummaryPage(this.workout, this.setsCompleted);

  void addTotal() async {
    List<Exercise> exercises = workout.routine.keys.toList();
    for (Exercise ex in exercises) {
      int completed =  workout.routine[ex] * setsCompleted;
      QuerySnapshot query = await Firestore.instance.collection('exercises')
          .where('name', isEqualTo: ex.name)
          .getDocuments();
      DocumentSnapshot doc = query.documents[0];
      doc.reference.updateData({
        'total': doc['total'] + completed
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 32),
                      Text('🎉', style: TextStyle(fontSize: 50)),
                      Text('You\'re done!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Text('You completed:', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 16),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: workout.routine.length,
                          itemBuilder: (context, index) {
                            Exercise ex = workout.routine.keys.toList()[index];
                            return Padding(
                                padding: EdgeInsets.only(left: 32, top: 6, bottom: 6),
                                child: Row(
                                    children: [
                                      Icon(Icons.check_circle),
                                      SizedBox(width: 8),
                                      Text(
                                          ex.name + ': ' + (workout.routine[ex] * setsCompleted).toString() + ' ' + ex.units,
                                          style: TextStyle(fontSize: 16)
                                      )
                                    ]
                                )
                            );
                          }
                      ),
                      SizedBox(height: 16),
                      RaisedButton(
                        child: Text('Back to home', style: TextStyle(color: Colors.white, fontSize: 20)),
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(32))
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          addTotal();
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      )
                    ]
                )
            )
        )
    );
  }
}

