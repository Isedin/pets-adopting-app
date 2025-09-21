import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/species_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/main.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  testWidgets("SplashScreen shows first and navigates to HomeScreen after ~1s", (tester) async {
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final petRepo = FirestorePetRepository(firestore: firestore, storage: storage);
    final speciesRepo = SpeciesRepository(firestore);

    await tester.pumpWidget(MyApp(firestoreRepo: petRepo, speciesRepo: speciesRepo));

    await tester.pumpAndSettle();

    // SplashScreen
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // HomeScreen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
