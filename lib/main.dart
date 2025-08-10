import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/owner.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/fake_pet_repository.dart';
import 'package:pummel_the_fish/screens/create_pet_screen.dart';
import 'package:pummel_the_fish/screens/home_screen.dart';
import 'package:pummel_the_fish/screens/splash_screen.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

void main() {
  final owner = Owner(id: "1", name: "Isedin");
  final pummelTheFish = Pet(
    id: "1",
    name: "Pummel",
    species: Species.fish,
    age: 2,
    weight: 1.5,
    height: 0.5,
    isFemale: false,
    birthday: DateTime(2021, 5, 20),
    owner: owner,
  );

  final brunoTheDog = Pet(
    id: "2",
    name: "Bruno",
    species: Species.dog,
    age: 3,
    weight: 4.0,
    height: 0.3,
    isFemale: true,
    birthday: DateTime(2020, 3, 15),
    owner: null,
  );

  // printOwnerNames([pummelTheFish, brunoTheDog]);

  final List<Pet> pets = [pummelTheFish, brunoTheDog];

  final age = pummelTheFish.getAgeInDays();
  print("Pummel's age in days: $age");
  print(pummelTheFish.name); // Output: Pummel
  print(pummelTheFish.species); // Output: Species.fish

  final petRepository = FakePetRepository();
  final allPets = petRepository.getAllPets();
  print("Total pets in repository: ${allPets.length}");

  // final coolPetName = FakePetRepository.makeACoolPetName(
  //   "Dieter",
  //   titleOfNobility: "Sir",
  //   species: Species.cat,
  //   coolAdjective: "deadly",
  // );
  // print("Cool pet name: $coolPetName");

  // final anotherCoolPetName = FakePetRepository.makeACoolPetName(
  //   "Fritz",
  //   titleOfNobility: "Duke",
  //   species: Species.dog,
  //   coolAdjective: "fierce",
  // );
  // print("Another cool pet name: $anotherCoolPetName");

  final anotherPets = [
    Pet(
      id: "3",
      name: "Whiskers",
      species: Species.cat,
      age: 4,
      weight: 3.0,
      height: 0.25,
    ),
    Pet(
      id: "4",
      name: "Rex",
      species: Species.dog,
      age: 5,
      weight: 5.0,
      height: 0.6,
    ),
  ];

  for (var pet in anotherPets) {
    print(pet.name);
  }

  // while (pets.length < 10) {
  //   pets.add(
  //     Pet(
  //       id: "${pets.length + 1}",
  //       name: "Pet ${pets.length + 1}",
  //       species: Species.values[pets.length % Species.values.length],
  //       age: (pets.length + 1) * 2,
  //       weight: (pets.length + 1) * 1.5,
  //       height: (pets.length + 1) * 0.2,
  //       isFemale: pets.length % 2 == 0,
  //       birthday: DateTime.now().subtract(
  //         Duration(days: (pets.length + 1) * 365),
  //       ),
  //     ),
  //   );
  // }
  // print("Total pets after adding more: ${pets.length}");

  // do {
  //   pets.add(
  //     Pet(
  //       id: "1",
  //       name: "name",
  //       species: Species.bird,
  //       age: age,
  //       weight: 200.00,
  //       height: 30.00,
  //       isFemale: true,
  //       birthday: DateTime.now(),
  //     ),
  //   );
  // } while (pets.length < 10);
  // print("Total pets after do-while loop: ${pets.length}");

  // final foodStream = Stream<String>.periodic(
  //   const Duration(seconds: 1),
  //   (count) => "Food item ${count + 1}",
  // ).take(5);
  // foodStream.listen((food) {
  //   print("Received food: $food");
  // });

  // final foodDeliveries = [
  //   "Fish flakes",
  //   "Dog kibble",
  //   "Cat treats",
  //   "Bird seeds",
  //   "Rabbit pellets",
  // ];

  // Stream<String> getFoodFromDelivery(List<String> foodDeliveries) async* {
  //   for (var food in foodDeliveries) {
  //     await Future.delayed(const Duration(seconds: 1));
  //     yield food;
  //   }
  // }

  // getFoodFromDelivery(foodDeliveries).listen((food) {
  //   print("Delivered food: $food");
  // });

  runApp(const MyApp());
}

// void printOwnerNames(List<Pet> pets) {
//   for (var pet in pets) {
//     if (pet.owner != null) {
//       print("Owner of ${pet.name}: ${pet.owner!.name}");
//     } else {
//       print("${pet.name} has no owner.");
//     }
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final brunoTheDog = Pet(
      id: "2",
      name: "Bruno",
      species: Species.dog,
      age: 3,
      weight: 4.0,
      height: 0.3,
      isFemale: true,
      // birthday: DateTime(2020, 3, 15),
      // owner: null,
    );
    final miauTheCat = Pet(
      id: "3",
      name: "Miau",
      species: Species.cat,
      age: 2,
      weight: 3.0,
      height: 0.25,
      isFemale: false,
      // birthday: DateTime(2021, 6, 10),
      // owner: null,
    );
    return MaterialApp(
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
      // home: const SplashScreen(),
      // home: const CreatePetScreen(),
      // home: DetailPetScreen(pet: miauTheCat),
      // home: const HomeScreen(),
      initialRoute: "/",
      routes: {
        "/": (context) => const SplashScreen(),
        "/home": (context) => const HomeScreen(),
        "/create": (context) => const CreatePetScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    print("Counter incremented to $_counter");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Text('You have pushed the button this many times:'),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
