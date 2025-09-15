import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pummel_the_fish/data/models/app_species.dart';

const speciesCollection = 'species';

class SpeciesRepository {
  final FirebaseFirestore firestore;
  SpeciesRepository(this.firestore);

  Stream<List<AppSpecies>> watchAll() {
    return firestore
        .collection(speciesCollection)
        .where('enabled', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AppSpecies.fromMap(d.data())).toList());
  }

  Future<void> addIfMissing({required String key, required String label}) async {
    final doc = await firestore.collection(speciesCollection).where('key', isEqualTo: key).limit(1).get();

    if (doc.docs.isEmpty) {
      await firestore.collection(speciesCollection).add({
        'key': key,
        'label': label,
        'builtin': false,
        'enabled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
