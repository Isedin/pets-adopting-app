import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';
import 'package:pummel_the_fish/theme/app_theme.dart';
import 'package:pummel_the_fish/widgets/create_pet_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      final cred = await FirebaseAuth.instance.signInAnonymously();
      if (kDebugMode) print('Signed in anonymously uid=${cred.user?.uid}');
    } else {
      if (kDebugMode) print('Already signed in uid=${user.uid}');
    }
  } catch (e) {
    if (kDebugMode) print('Anonymous sign-in failed: $e');
  }

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);
  final firestoreRepo = FirestorePetRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );

  runApp(MyApp(firestoreRepo: firestoreRepo));
  final user = FirebaseAuth.instance.currentUser;
  debugPrint('AUTH user: ${user?.uid}  isAnon=${user?.isAnonymous}');
}

class MyApp extends StatelessWidget {
  final FirestorePetRepository firestoreRepo;
  const MyApp({super.key, required this.firestoreRepo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PetRepository>.value(
      value: firestoreRepo,
      child: MaterialApp(
        darkTheme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        title: 'Pummel The Fish',
        theme: buildAppTheme(),

        initialRoute: "/",
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(builder: (context) => const SplashScreen());
          }
          if (settings.name == '/home') {
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          }
          if (settings.name == '/create') {
            final petToEdit = settings.arguments as Pet?;
            final repo = firestoreRepo;
            return MaterialPageRoute(
              builder: (_) => CreatePetRoute(petToEdit: petToEdit, repo: repo),
            );
          }
          return null;
        },
      ),
    );
  }
}
