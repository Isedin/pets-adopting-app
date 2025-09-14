// lib/data/mappers/pet_mapper.dart
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetMapper {
  /// Firestore Map -> Domain Pet
  static Pet fromFirestore(Map<String, dynamic> map, String id) {
    double _asDouble(dynamic v) => v == null ? 0.0 : double.parse(v.toString());
    final ageRaw = map['age'] ?? map['age_in_years'] ?? 0;

    DateTime? _asDateTime(dynamic v) {
      if (v == null) return null;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is Timestamp) return v.toDate();
      return null;
    }

    Owner? _ownerFrom(dynamic v) {
      if (v is Map<String, dynamic>) return Owner.fromMap(v);
      return null;
    }

    // Prihvati i novu i legacy šemu:
    // - prefer 'species' string (npr. "fish")
    // - fallback: 'speciesType' / int enum
    final dynamic raw = map['species'] ?? map['speciesType'];
    final String speciesStr = switch (raw) {
      String s => s,
      int i => i.toString(),
      _ => 'other',
    };

    return Pet(
      id: id,
      name: (map['name'] ?? '') as String,
      species: SpeciesX.fromString(speciesStr),
      age: int.parse(ageRaw.toString()),
      weight: _asDouble(map['weight']),
      height: _asDouble(map['height']),
      isFemale: (map['isFemale'] ?? map['is_female']) as bool?,
      birthday: _asDateTime(map['birthday']),
      owner: _ownerFrom(map['owner']),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  /// Domain Pet -> Firestore Map
  static Map<String, dynamic> toFirestore(Pet p) {
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
      // spremamo kao jednostavan ključ
      'species': p.species.name, // npr. "fish"
      'age': p.age,
      'weight': p.weight,
      'height': p.height,
      'isFemale': p.isFemale,
      'birthday': p.birthday?.millisecondsSinceEpoch,
      'owner': p.owner?.toMap(),
      'imageUrl': p.imageUrl,
    };
  }
}
