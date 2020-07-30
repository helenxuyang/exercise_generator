import 'dart:math';

class Exercise {
  Exercise(this.name, this.min, this.max, this.units, this.imageURL);
  String name;
  int min;
  int max;
  String units;
  String imageURL;

  int getRandomNum() {
    return Random().nextInt(max - min) + min;
  }
}