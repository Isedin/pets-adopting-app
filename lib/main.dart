import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/bloc/create_pet_cubit.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/screens/create_pet_screen.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';
import 'package:pummel_the_fish/theme/app_theme.dart';
import 'package:pummel_the_fish/widgets/adoption_bag_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestoreRepo = FirestorePetRepository(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );

  runApp(MyApp(firestoreRepo: firestoreRepo));
}

class MyApp extends StatelessWidget {
  final FirestorePetRepository firestoreRepo;
  const MyApp({super.key, required this.firestoreRepo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdoptionBagWrapper(
      child: RepositoryProvider.value(
        value: firestoreRepo,
        child: MaterialApp(
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          title: 'Pummel The Fish',
          theme: buildAppTheme(),

          initialRoute: "/",
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              );
            }
            if (settings.name == '/home') {
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            }
            if (settings.name == '/create') {
              final petToEdit = settings.arguments as Pet?;
              return MaterialPageRoute(
                builder: (context) => BlocProvider<CreatePetCubit>(
                  create: (context) => CreatePetCubit(
                    petRepository:
                        RepositoryProvider.of<FirestorePetRepository>(context),
                  ),
                  child: CreatePetScreen(petToEdit: petToEdit),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
