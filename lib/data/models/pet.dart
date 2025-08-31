// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

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
  final String? imageUrl;

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
    this.imageUrl,
  });

  factory Pet.fromJson(String source) =>
      Pet.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Pet.fromMap(Map<String, dynamic> map, [String? id]) {
    final speciesValue = map["species"] is int
        ? map["species"]
              .toString() // Ako je int, pretvori u string
        : map["species"] as String; // Inače, pretpostavi da je string
    return Pet(
      id: id ?? map["id"] ?? '',
      name: map["name"] as String,
      species: Species.fromString(speciesValue),
      // ACHTUNG: Unser JavaScript Backend liefert für einen Wert von "1.0" nur "1" zurück,
      // daher müssen wir das an dieser Stelle zunächst in einen String umwandeln,
      // um danach einen double daraus machen zu können.
      weight: double.parse(map["weight"].toString()),
      height: double.parse(map["height"].toString()),
      age: map["age"] ?? map["age_in_years"] as int,
      isFemale: map["isFemale"] ?? map["is_female"] as bool?,
      owner: map["owner"] != null ? Owner.fromMap(map["owner"]) : null,
      imageUrl: map["imageUrl"] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'species': species.toString().split('.').last,
      'age': age,
      'weight': weight,
      'height': height,
      'isFemale': isFemale,
      'birthday': birthday?.millisecondsSinceEpoch,
      'owner': owner?.toMap(),
      'imageUrl': imageUrl,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  int getAgeInDays() {
    return DateTime.now().difference(birthday ?? DateTime.now()).inDays;
  }

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, species: $species, age: $age, weight: $weight, height: $height, isFemale: $isFemale, birthday: $birthday, owner: $owner, imageUrl: $imageUrl)';
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
        other.owner == owner &&
        other.imageUrl == imageUrl;
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
        owner.hashCode ^
        imageUrl.hashCode;
  }
}
