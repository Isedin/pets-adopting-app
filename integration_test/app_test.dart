import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/main.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  testWidgets(
    "SplashScreen shows first and changes to HomeScreen after 2 seconds",
    (tester) async {
      final repo = FirestorePetRepository(
        firestore: FirebaseFirestore.instance,
        storage: FirebaseStorage.instance,
      );
      await tester.pumpWidget(MyApp(firestoreRepo: repo));

      await tester.pumpAndSettle();

      //SplashScreen
      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      //HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}
