import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetMapper {
  /// Firestore Map -> Domain Pet
  static Pet fromFirestore(Map<String, dynamic> map, String id) {
    // species can come as int or string
    final speciesRaw = map['species'];
    final speciesStr = speciesRaw is int
        ? speciesRaw.toString()
        : (speciesRaw as String);

    // double fields can come as int (e.g., 1 instead of 1.0)
    double _asDouble(dynamic v) => v == null ? 0.0 : double.parse(v.toString());

    // age can be 'age' or 'age_in_years'
    final ageRaw = map['age'] ?? map['age_in_years'] ?? 0;

    // birthday: int (millis) or Firestore Timestamp or null
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

    return Pet(
      id: id,
      name: map['name'] as String,
      species: Species.fromString(speciesStr),
      age: int.parse(ageRaw.toString()),
      weight: _asDouble(map['weight']),
      height: _asDouble(map['height']),
      isFemale: map['isFemale'] ?? map['is_female'] as bool?,
      birthday: _asDateTime(map['birthday']),
      owner: _ownerFrom(map['owner']),
      imageUrl: map['imageUrl'] as String?,
    );
    // Notice: there is no Firestore dependency in Pet - it's all here.
  }

  /// Domain Pet -> Firestore Map
  static Map<String, dynamic> toFirestore(Pet p) {
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
      'species': p.species.toString().split('.').last, // npr. "fish"
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
