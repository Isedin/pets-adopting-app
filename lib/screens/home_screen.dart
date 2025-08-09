import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/fake_pet_repository.dart';

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
        title: const Text("Home Screen"),
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
                  color: const Color(0xFFFFC942),
                  size: 40,
                ),
                title: Text(pets[index].name),
                subtitle: Text("Alter: ${pets[index].age} Jahre"),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // Navigate to detail screen or perform an action
                  print("Tapped on ${pets[index].name}");
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // setState(() {
          //   pets = petRepository.getAllPets();
          // });
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
