import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/fake_pet_repository.dart';
import 'package:pummel_the_fish/screens/detail_pet_screen.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final petRepository = FakePetRepository();
  List<Pet> pets = [];

  @override
  void initState() {
    super.initState();
    pets = petRepository.getAllPets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/images/pummel.png', fit: BoxFit.cover),
        ),
        title: const Text("Pummel the Fish"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  (pets[index].isFemale ?? false) ? Icons.female : Icons.male,
                  color: CustomColors.orange,
                  size: 40,
                ),
                title: Text(
                  pets[index].name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  "Alter: ${pets[index].age} Jahre",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  color: CustomColors.blueMedium,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailPetScreen(pet: pets[index]),
                    ),
                  );
                  print("Tapped on ${pets[index].name}");
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/create");
          print("Navigating to CreatePetScreen");
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
