import 'package:flutter/material.dart';
import 'Home.dart';
import 'Exercises.dart';
import 'History.dart';
import 'Profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSans',
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          headline2: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[700])
        )
      ),
      home: SafeArea(
          child: MainPage()
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const int HOME = 0;
  static const int EXERCISES = 1;
  static const int CALENDAR = 2;
  static const int PROFILE = 3;

  int currentIndex = 0;

  Widget getPage(BuildContext context, int selection) {
    switch (currentIndex) {
      case HOME: return HomePage();
      case EXERCISES: return ExercisesPage();
      case CALENDAR: return HistoryPage();
      case PROFILE: return ProfilePage();
      default: return Column();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(icon: Icon(Icons.fitness_center), title: Text('Exercises')),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today), title: Text('Calendar')),
              BottomNavigationBarItem(icon: Icon(Icons.person), title: Text('Profile'))
            ],
            currentIndex: currentIndex,
            onTap: (int index) {
              setState(() {
                currentIndex = index;
              });
            }
        ),
        floatingActionButton: currentIndex == EXERCISES ? FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => NewExercisePage()));
          },
        ) : null,
        body: getPage(context, currentIndex)
    );
  }
}

