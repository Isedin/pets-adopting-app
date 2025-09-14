// lib/data/mappers/pet_rest_mapper.dart
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetRestMapper {
  static Pet fromJson(Map<String, dynamic> map) {
    double _asDouble(dynamic v) => v == null ? 0.0 : double.parse(v.toString());
    final ageRaw = map['age'] ?? map['age_in_years'] ?? 0;

    Owner? _ownerFrom(dynamic v) {
      if (v is Map<String, dynamic>) return Owner.fromMap(v);
      return null;
    }

    final speciesStr = (map['species'] ?? map['speciesType'] ?? 'other').toString();

    return Pet(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '') as String,
      species: SpeciesX.fromString(speciesStr),
      age: int.parse(ageRaw.toString()),
      weight: _asDouble(map['weight']),
      height: _asDouble(map['height']),
      isFemale: map['isFemale'] as bool?,
      birthday: map['birthday'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              int.parse(map['birthday'].toString()),
            )
          : null,
      owner: _ownerFrom(map['owner']),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  static Map<String, dynamic> toJson(Pet p) {
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
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
