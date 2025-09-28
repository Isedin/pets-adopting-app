import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/species_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/screens/auth/auth_gate.dart';
import 'package:pummel_the_fish/theme/app_theme.dart';
import 'package:pummel_the_fish/widgets/create_pet_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final firestoreRepo = FirestorePetRepository(
    firestore: firestore,
    storage: storage,
  );
  final speciesRepo = SpeciesRepository(firestore);

  runApp(MyApp(firestoreRepo: firestoreRepo, speciesRepo: speciesRepo));
}

class MyApp extends StatelessWidget {
  final FirestorePetRepository firestoreRepo;
  final SpeciesRepository speciesRepo;

  const MyApp({
    super.key,
    required this.firestoreRepo,
    required this.speciesRepo,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PetRepository>.value(value: firestoreRepo),
        RepositoryProvider<SpeciesRepository>.value(value: speciesRepo),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pummel The Fish',
          theme: buildAppTheme(),
          darkTheme: ThemeData.dark(),
          home: const AuthGate(), // entrypoint => login or home
          onGenerateRoute: (settings) {
            if (settings.name == '/create') {
              final user = FirebaseAuth.instance.currentUser;
              // nije prijavljen ili anoniman
              if (user == null || user.isAnonymous) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text('Please log in to add pets for adoption.'),
                    ),
                  ),
                );
              }
              // zahtijevaj verifikovan email
              if (!user.emailVerified) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text(
                        'Verify your email to add pets for adoption.',
                      ),
                    ),
                  ),
                );
              }
              final petToEdit = settings.arguments as Pet?;
              return MaterialPageRoute(
                builder: (_) =>
                    CreatePetRoute(petToEdit: petToEdit, repo: firestoreRepo),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
