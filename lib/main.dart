import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/chat_repository.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/species_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/logic/cubits/auth_cubit.dart';
import 'package:pummel_the_fish/screens/auth/auth_gate.dart';
import 'package:pummel_the_fish/services/chat_crypto.dart';
import 'package:pummel_the_fish/theme/app_theme.dart';
import 'package:pummel_the_fish/widgets/create_pet_route.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch uncaught Flutter errors → log or show fallback
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

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

final GlobalKey<ScaffoldMessengerState> rootMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();


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
        RepositoryProvider<ChatCrypto>(create: (_) => ChatCrypto()),
        RepositoryProvider<ChatRepository>(
          create: (ctx) => ChatRepository(
            firestore: FirebaseFirestore.instance,
            crypto: ctx.read<ChatCrypto>(),
          ),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (ctx) => AuthCubit(
          // crypto: ctx.read<ChatCrypto>(),
        ),
        child: MaterialApp(
          scaffoldMessengerKey: rootMessengerKey,
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Pummel The Fish',
          theme: buildAppTheme(),
          darkTheme: ThemeData.dark(),
          home: const AuthGate(), // entrypoint => login or home
          onGenerateRoute: (settings) {
            if (settings.name == '/create') {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null || user.isAnonymous) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text('Please log in to add pets for adoption.'),
                    ),
                  ),
                );
              }
              // ask user to verify email
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
