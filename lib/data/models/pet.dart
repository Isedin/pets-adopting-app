// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pummel_the_fish/data/models/owner.dart';

enum Species { dog, cat, fish, bird }

extension SpeciesX on Species {
  static Species fromString(String value) {
    switch (value.toLowerCase()) {
      case "dog":
        return Species.dog;
      case "cat":
        return Species.cat;
      case "fish":
        return Species.fish;
      case "bird":
        return Species.bird;
      default:
        throw Exception("Unknown species: $value");
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }
}

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

  factory Pet.fromJson(String source) =>
      Pet.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Pet.fromMap(Map<String, dynamic> map, [String? id]) {
    return Pet(
      id: id ?? map["id"] ?? '',
      name: map["name"],
      species: map["species"] is int
          ? Species.values[map["species"]]
          : SpeciesX.fromString(map["species"].toString()),
      // ACHTUNG: Unser JavaScript Backend liefert für einen Wert von "1.0" nur "1" zurück,
      // daher müssen wir das an dieser Stelle zunächst in einen String umwandeln,
      // um danach einen double daraus machen zu können.
      weight: double.parse(map["weight"].toString()),
      height: double.parse(map["height"].toString()),
      age: map["age"] ?? map["age_in_years"] as int,
      isFemale: map["isFemale"] ?? map["is_female"] as bool?,
      owner: map["owner"] != null ? Owner.fromMap(map["owner"]) : null,
    );
  }

  String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'species': species.toShortString(),
      'age': age,
      'weight': weight,
      'height': height,
      'isFemale': isFemale,
      'birthday': birthday?.millisecondsSinceEpoch,
      'owner': owner?.toMap(),
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    Species? species,
    int? age,
    double? weight,
    double? height,
    bool? isFemale,
    DateTime? birthday,
    Owner? owner,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      isFemale: isFemale ?? this.isFemale,
      birthday: birthday ?? this.birthday,
      owner: owner ?? this.owner,
    );
  }

  int getAgeInDays() {
    return DateTime.now().difference(birthday ?? DateTime.now()).inDays;
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, species: $species, age: $age, weight: $weight, height: $height, isFemale: $isFemale, birthday: $birthday, owner: $owner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pet &&
        other.id == id &&
        other.name == name &&
        other.species == species &&
        other.age == age &&
        other.weight == weight &&
        other.height == height &&
        other.isFemale == isFemale &&
        other.birthday == birthday &&
        other.owner == owner;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        species.hashCode ^
        age.hashCode ^
        weight.hashCode ^
        height.hashCode ^
        isFemale.hashCode ^
        birthday.hashCode ^
        owner.hashCode;
  }
}
