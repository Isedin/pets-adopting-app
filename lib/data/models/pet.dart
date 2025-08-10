import 'package:pummel_the_fish/data/models/owner.dart';
import 'dart:convert';

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

  factory Pet.fromJson(String source) => Pet.fromMap(jsonDecode(source));
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map["id"],
      name: map["name"],
      species: Species.values[map["species"]],
      // ACHTUNG: Unser JavaScript Backend liefert für einen Wert von "1.0" nur "1" zurück,
      // daher müssen wir das an dieser Stelle zunächst in einen String umwandeln,
      // um danach einen double daraus machen zu können.
      weight: double.parse(map["weight"].toString()),
      height: double.parse(map["height"].toString()),
      age: map["age_in_years"] as int,
      isFemale: map["is_female"],
      owner: map["owner"] != null ? Owner.fromMap(map["owner"]) : null,
    );
  }

  int getAgeInDays() {
    return DateTime.now().difference(birthday ?? DateTime.now()).inDays;
  }

  @override
  String toString() {
    return "Pet(id: $id, name: $name, species: $species, weight: $weight, height: $height, age: $age, isFemale: $isFemale, owner: $owner,)";
  }
}
