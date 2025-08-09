import 'package:pummel_the_fish/data/models/owner.dart';

enum Species { dog, cat, fish, bird }

class Pet {
  final String id;
  final String name;
  final Species species;
  final int age;
  final double weight;
  final double height;
  final bool? isFemale;
  final DateTime? birthday;
  final Owner? owner;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.age,
    required this.weight,
    required this.height,
    this.isFemale,
    this.birthday,
    this.owner,
  });

  int getAgeInDays() {
    return DateTime.now().difference(birthday ?? DateTime.now()).inDays;
  }

  @override
  String toString() {
    return "Pet(id: $id, name: $name, species: $species, weight: $weight, height: $height, age: $age, isFemale: $isFemale, owner: $owner,)";
  }
}
