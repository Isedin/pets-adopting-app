import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/firebase_options.dart';
import 'package:pummel_the_fish/screens/create_pet_screen.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/adoption_bag_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdoptionBagWrapper(
      child: RepositoryProvider(
        create: (context) =>
            FirestorePetRepository(firestore: FirebaseFirestore.instance),
        child: MaterialApp(
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          title: 'Pummel The Fish',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: const ColorScheme.light(
              brightness: Brightness.light,
              primary: CustomColors.blueDark,
              onPrimary: Colors.white,
              secondary: Colors.amber,
              onSecondary: Colors.white,
              surface: CustomColors.blueLight,
              onSurface: CustomColors.white,
            ),
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: CustomColors.blueDark,
              ),
              floatingLabelStyle: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: CustomColors.blueDark,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: CustomColors.blueDark),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: CustomColors.blueLight),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: CustomColors.red),
              ),
            ),
            fontFamily: 'Comfortaa',
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: CustomColors.blueDark,
              ),
              titleMedium: TextStyle(
                fontFamily: "Comfortaa",
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: CustomColors.blueMedium,
              ),
              bodyLarge: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: CustomColors.blueDark,
              ),
              bodyMedium: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: CustomColors.white,
              ),
              bodySmall: TextStyle(
                fontFamily: "Titillium Web",
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: CustomColors.blueDark,
              ),
            ),
          ),

          initialRoute: "/",
          routes: {
            "/": (context) => const SplashScreen(),
            "/home": (context) => const HomeScreen(),
            "/create": (context) => const CreatePetScreen(),
          },
        ),
      ),
    );
  }
}
