import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetMapper {
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

    List<String>? _asStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) return v.map((e) => e.toString()).toList();
      return null;
    }

    return Pet(
      id: id,
      name: (map['name'] ?? '') as String,
      species: speciesFromKey(map['species']?.toString()),
      speciesCustom: map['speciesCustom']?.toString(),
      age: int.parse(ageRaw.toString()),
      weight: _asDouble(map['weight']),
      height: _asDouble(map['height']),
      isFemale: (map['isFemale'] ?? map['is_female']) as bool?,
      birthday: _asDateTime(map['birthday']),
      owner: _ownerFrom(map['owner']),
      imageUrl: map['imageUrl'] as String?,

      // health (podržavamo i legacy typo "deseases")
      vaccinated: map['vaccinated'] as bool?,
      vaccines: _asStringList(map['vaccines']),
      hasDiseases: (map['hasDiseases'] ?? map['hasDeseases']) as bool?,
      diseases: _asStringList(map['diseases'] ?? map['deseases']),
    );
  }

  static Map<String, dynamic> toFirestore(Pet p) {
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
      'species': p.species.name,
      if (p.species == Species.other && (p.speciesCustom?.trim().isNotEmpty ?? false)) 'speciesCustom': p.speciesCustom,
      'age': p.age,
      'weight': p.weight,
      'height': p.height,
      'isFemale': p.isFemale,
      'birthday': p.birthday?.millisecondsSinceEpoch,
      'owner': p.owner?.toMap(),
      'imageUrl': p.imageUrl,

      // health (kanonska imena)
      'vaccinated': p.vaccinated,
      'vaccines': p.vaccines,
      'hasDiseases': p.hasDiseases,
      'diseases': p.diseases,
    };
  }
}
