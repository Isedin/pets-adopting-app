// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class Pet {
  final String id;
  final String name;
  final Species species;

  /// Ako je [species] == Species.other, koristi se ovaj *custom label* (slobodan string).
  final String? speciesCustom;

  final int age;
  final double weight;
  final double height;
  final bool? isFemale;
  final DateTime? birthday;
  final Owner? owner;
  final String? imageUrl;

  // Zdravstveni podaci
  final bool? vaccinated;
  final List<String>? vaccines;
  final bool? hasDiseases;
  final List<String>? diseases;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.speciesCustom,
    required this.age,
    required this.weight,
    required this.height,
    this.isFemale,
    this.birthday,
    this.owner,
    this.imageUrl,
    this.vaccinated,
    this.vaccines,
    this.hasDiseases,
    this.diseases,
  });

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'species': species.name,
      if (species == Species.other &&
          (speciesCustom?.trim().isNotEmpty ?? false))
        'speciesCustom': speciesCustom,
      'age': age,
      'weight': weight,
      'height': height,
      'isFemale': isFemale,
      'birthday': birthday?.millisecondsSinceEpoch,
      'owner': owner?.toMap(),
      'imageUrl': imageUrl,

      // health
      'vaccinated': vaccinated,
      'vaccines': vaccines,
      'hasDiseases': hasDiseases,
      'diseases': diseases,
    };
  }

  Pet copyWith({
    String? id,
    String? name,
    Species? species,
    String? speciesCustom,
    int? age,
    double? weight,
    double? height,
    bool? isFemale,
    DateTime? birthday,
    Owner? owner,
    String? imageUrl,
    bool? vaccinated,
    List<String>? vaccines,
    bool? hasDiseases,
    List<String>? diseases,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      speciesCustom: speciesCustom ?? this.speciesCustom,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      isFemale: isFemale ?? this.isFemale,
      birthday: birthday ?? this.birthday,
      owner: owner ?? this.owner,
      imageUrl: imageUrl ?? this.imageUrl,
      vaccinated: vaccinated ?? this.vaccinated,
      vaccines: vaccines ?? this.vaccines,
      hasDiseases: hasDiseases ?? this.hasDiseases,
      diseases: diseases ?? this.diseases,
    );
  }

  int getAgeInDays() =>
      DateTime.now().difference(birthday ?? DateTime.now()).inDays;

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, species: $species, speciesCustom: $speciesCustom, age: $age, weight: $weight, height: $height, isFemale: $isFemale, birthday: $birthday, owner: $owner, imageUrl: $imageUrl, vaccinated: $vaccinated, vaccines: $vaccines, hasDiseases: $hasDiseases, diseases: $diseases)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Pet &&
        other.id == id &&
        other.name == name &&
        other.species == species &&
        other.speciesCustom == speciesCustom &&
        other.age == age &&
        other.weight == weight &&
        other.height == height &&
        other.isFemale == isFemale &&
        other.birthday == birthday &&
        other.owner == owner &&
        other.imageUrl == imageUrl &&
        other.vaccinated == vaccinated &&
        _listEq(other.vaccines, vaccines) &&
        other.hasDiseases == hasDiseases &&
        _listEq(other.diseases, diseases);
  }

  static bool _listEq(List? a, List? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        species.hashCode ^
        (speciesCustom ?? '').hashCode ^
        age.hashCode ^
        weight.hashCode ^
        height.hashCode ^
        (isFemale ?? false).hashCode ^
        (birthday?.millisecondsSinceEpoch ?? 0).hashCode ^
        owner.hashCode ^
        (imageUrl ?? '').hashCode ^
        (vaccinated ?? false).hashCode ^
        (vaccines?.join('|') ?? '').hashCode ^
        (hasDiseases ?? false).hashCode ^
        (diseases?.join('|') ?? '').hashCode;
  }
}
