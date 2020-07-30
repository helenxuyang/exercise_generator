import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExercisesPage extends StatelessWidget {

  Widget _buildExerciseCard(BuildContext context, DocumentSnapshot doc) {
    return Padding(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
                children: [
                  CachedNetworkImage(
                      imageUrl: doc['image'],
                      width: MediaQuery.of(context).size.width / 5,
                      placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error)
                  ),
                  SizedBox(width: 20),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc['name'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(doc['min'].toString() + ' to ' + doc['max'].toString() + ' ' + doc['units'], style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              /*Text('💪 🆎'),
                              SizedBox(width: 16),*/
                              Text('Total done: ' + doc['total'].toString() + ' ' + doc['units'])
                            ]
                        )
                      ]
                  )
                ]
            )
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
              padding: EdgeInsets.all(16),
              child: Text('Your Exercises', style: Theme.of(context).textTheme.headline1)
          ),
          StreamBuilder(
              stream: Firestore.instance.collection('exercises').snapshots(),
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
                  return Expanded(
                    child: Scrollbar(
                      child: ListView.separated(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return _buildExerciseCard(context, snapshot.data.documents[index]);
                        },
                        separatorBuilder: (context, index) {
                          return Divider();
                        },
                      ),
                    ),
                  );
                }
              }
          )
        ]
    );
  }
}

class NewExercisePage extends StatefulWidget {
  @override
  _NewExercisePageState createState() => _NewExercisePageState();
}

class _NewExercisePageState extends State<NewExercisePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();
  String name;
  int min;
  int max;
  String units = 'repetitions';
  List<bool> targetsSelected = List<bool>.filled(4, false);

  void addExercise(String name, int min, int max, String units) async {
    CollectionReference exercisesCollection = Firestore.instance.collection('exercises');
    await exercisesCollection.add({
      'name': name,
      'min': min,
      'max': max,
      'units': units,
      'total': 0
    });
  }

  Widget toggleButton(String emoji, String text) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
            children: [
              Text(emoji, style: TextStyle(fontSize: 24)),
              Text(text, style: TextStyle(fontSize: 18))
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Center(
              child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Create new exercise', style: Theme.of(context).textTheme.headline1),
                    ),
                    Form(
                        key: formKey,
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                                children: [
                                  Text('Exercise name', style: Theme.of(context).textTheme.headline2),
                                  TextFormField(
                                      autofocus: true,
                                      textInputAction: TextInputAction.next,
                                      onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                      validator: (input) {
                                        if (input.isEmpty) return 'Enter an exercise name.';
                                        return null;
                                      },
                                      onSaved: (input) {
                                        setState(() {
                                          name = input;
                                        });
                                      }
                                  ),
                                  SizedBox(height: 32),
                                  Text('Range', style: Theme.of(context).textTheme.headline2),
                                  Row(
                                      children: [
                                        Expanded(
                                            child: TextFormField(
                                                textInputAction: TextInputAction.next,
                                                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                                                controller: minController,
                                                keyboardType: TextInputType.number,
                                                validator: (input) {
                                                  if (input.isEmpty) return 'Enter min.';
                                                  if (input.contains(',') || input.contains('.') || input.contains('-') || input.contains(' ')) return 'Min should only contain numbers.';
                                                  if (int.parse(input) == 0) return 'Min should be greater than 0.';
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                    errorMaxLines: 3
                                                ),
                                                onSaved: (input) {
                                                  setState(() {
                                                    min = int.parse(input);
                                                  });
                                                }
                                            )
                                        ),
                                        Padding(
                                            padding: EdgeInsets.only(left: 8, right: 8),
                                            child: Text('to', style: TextStyle(fontSize: 16))
                                        ),
                                        Expanded(
                                            child: TextFormField(
                                                controller: maxController,
                                                keyboardType: TextInputType.number,
                                                validator: (input) {
                                                  if (input.isEmpty) return 'Enter max.';
                                                  if (input.contains(',') || input.contains('.') || input.contains('-') || input.contains(' ')) return 'Max should only contain numbers.';
                                                  if (int.parse(input) == 0) return 'Max should be greater than 0.';
                                                  if (int.parse(input) < int.parse(minController.text)) return 'Max should be greater than min.';
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                    errorMaxLines: 3
                                                ),
                                                onSaved: (input) {
                                                  setState(() {
                                                    max = int.parse(input);
                                                  });
                                                }
                                            )
                                        ),
                                        SizedBox(width: 8),
                                        DropdownButton(
                                          value: units,
                                          items: ['repetitions', 'seconds', 'minutes']
                                              .map((String value) {
                                            return DropdownMenuItem<String>(value: value, child: Text(value));
                                          }).toList()
                                          ,
                                          onChanged: (selection) {
                                            setState(() {
                                              units = selection;
                                            });
                                          },
                                        )
                                      ]
                                  ),
                                  SizedBox(height: 32),
                                  /*Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Select target areas:', style: Theme.of(context).textTheme.headline2),
                                  ),
                                  targetChips,*/
                                  /*SizedBox(height: 16),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text('Select equipment:', style: Theme.of(context).textTheme.headline2),
                                  ),
                                  equipmentChips,
                                  SizedBox(height: 32),*/
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        RaisedButton(
                                          child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 20)),
                                          color: Colors.red[600],
                                          padding: EdgeInsets.only(top: 16, bottom: 16, left: 40, right: 40),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(32))
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              Navigator.pop(context);
                                            });
                                          },
                                        ),
                                        RaisedButton(
                                          child: Text('Create', style: TextStyle(color: Colors.white, fontSize: 20)),
                                          color: Colors.blue,
                                          padding: EdgeInsets.only(top: 16, bottom: 16, left: 40, right: 40),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(32))
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (formKey.currentState.validate()) {
                                                formKey.currentState.save();
                                                addExercise(name, min, max, units);
                                                Navigator.pop(context);
                                              }
                                            });
                                          },
                                        ),
                                      ]
                                  )
                                ]
                            )
                        )
                    ),
                  ]
              ),
            )
        )
    );
  }
}


