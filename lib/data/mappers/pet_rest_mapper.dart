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

    List<String>? _asStringList(dynamic v) {
      if (v == null) return null;
      if (v is List) return v.map((e) => e.toString()).toList();
      return null;
    }

    return Pet(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '') as String,
      species: speciesFromKey(map['species']?.toString()),
      speciesCustom: map['speciesCustom']?.toString(),
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

      vaccinated: map['vaccinated'] as bool?,
      vaccines: _asStringList(map['vaccines']),
      hasDiseases: (map['hasDiseases'] ?? map['hasDeseases']) as bool?,
      diseases: _asStringList(map['diseases'] ?? map['deseases']),
    );
  }

  static Map<String, dynamic> toJson(Pet p) {
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
      'species': p.species.name,
      if (p.species == Species.other &&
          (p.speciesCustom?.trim().isNotEmpty ?? false))
        'speciesCustom': p.speciesCustom,
      'age': p.age,
      'weight': p.weight,
      'height': p.height,
      'isFemale': p.isFemale,
      'birthday': p.birthday?.millisecondsSinceEpoch,
      'owner': p.owner?.toMap(),
      'ownerId': p.owner?.id,
      'imageUrl': p.imageUrl,

      'vaccinated': p.vaccinated,
      'vaccines': p.vaccines,
      'hasDiseases': p.hasDiseases,
      'diseases': p.diseases,
    };
  }
}
