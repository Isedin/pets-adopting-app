import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetMapper {
  // Firestore -> Domain
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

    // species (legacy tolerant)
    final raw = map['species'];
    final speciesStr = (raw is String) ? raw : raw?.toString() ?? 'dog';
    final s = SpeciesX.fromStringSafe(speciesStr);

    // custom label (if Other)
    final custom = (map['speciesCustom'] as String?)?.trim();

    // 👇 NEW: fallback za legacy dok. only with ownerId
    Owner? owner = _ownerFrom(map['owner']);
    final legacyOwnerId = map['ownerId'] as String?;
    if (owner == null && legacyOwnerId != null && legacyOwnerId.isNotEmpty) {
      owner = Owner(id: legacyOwnerId, name: '');
    }

    return Pet(
      id: id,
      name: (map['name'] ?? '') as String,
      species: s,
      speciesCustom: custom?.isEmpty == true ? null : custom,
      age: int.parse(ageRaw.toString()),
      weight: _asDouble(map['weight']),
      height: _asDouble(map['height']),
      isFemale: (map['isFemale'] ?? map['is_female']) as bool?,
      birthday: _asDateTime(map['birthday']),
      owner: owner,
      imageUrl: map['imageUrl'] as String?,
      vaccinated: map['vaccinated'] as bool?,
      vaccines: (map['vaccines'] as List?)?.map((e) => e.toString()).toList(),
      hasDiseases: map['hasDiseases'] as bool?,
      diseases: (map['diseases'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  // Domain -> Firestore
  static Map<String, dynamic> toFirestore(Pet p) {
    final speciesKey = _speciesKeyFor(p);
    final speciesLabel = _speciesLabelFor(p);
    return <String, dynamic>{
      'id': p.id,
      'name': p.name,
      'species': p.species.name,               // legacy-compatible
      'speciesCustom': p.speciesCustom,        // if other
      'speciesKey': speciesKey,                // denormalization
      'speciesLabel': speciesLabel,            // denormalization

      'age': p.age,
      'weight': p.weight,
      'height': p.height,
      'isFemale': p.isFemale,
      'birthday': p.birthday?.millisecondsSinceEpoch,

      'owner': p.owner?.toMap(),
      'ownerId': p.owner?.id,                  // setting ownerId

      'imageUrl': p.imageUrl,
      'vaccinated': p.vaccinated,
      'vaccines': p.vaccines,
      'hasDiseases': p.hasDiseases,
      'diseases': p.diseases,
    };
  }

  static String _speciesKeyFor(Pet p) {
    if (p.species == Species.other) {
      final c = (p.speciesCustom ?? '').trim();
      if (c.isEmpty) return 'other';
      return c.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    }
    return p.species.name;
  }

  static String _speciesLabelFor(Pet p) {
    if (p.species == Species.other) {
      final c = (p.speciesCustom ?? '').trim();
      return c.isEmpty ? 'Andere' : c;
    }
    return p.species.displayName;
  }
}
