import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/rest_pet_repository.dart';
import 'package:pummel_the_fish/widgets/pet_list_error.dart';
import 'package:pummel_the_fish/widgets/pet_list_loaded.dart';
import 'package:pummel_the_fish/widgets/pet_list_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final RestPetRepository restPetRepository;
  late Future<List<Pet>> pets;

  @override
  void initState() {
    super.initState();
    final httpClient = http.Client();
    restPetRepository = RestPetRepository(httpClient);
    pets = restPetRepository.getAllPets();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<Pet>> _getAllPets() async {
      final httpClient = http.Client();
      final restPetRepository = RestPetRepository(httpClient);

      final pets = await restPetRepository.getAllPets();
      return pets;
    }

    // Future<void> _getPetById() async {
    //   final httpClient = http.Client();
    //   final restPetRepository = RestPetRepository(httpClient);

    //   // Replace 'somePetId' with a valid pet ID, e.g., pets.isNotEmpty ? pets.first.id : null
    //   final pet = await restPetRepository.getPetById(
    //     pets.isNotEmpty ? pets.first.id : '',
    //   );
    //   print(pet?.id);
    // }

    Future<void> _addNewPet(Pet pet) async {
      final httpClient = http.Client();
      final restPetRepository = RestPetRepository(httpClient);

      try {
        await restPetRepository.addPet(pet);
        print("New pet added: ${pet.name}");
      } catch (e) {
        print("Error adding new pet: $e");
      }
    }

    final newPet = Pet(
      id: 'new_pet_id',
      name: 'New Pet',
      age: 2,
      height: 30.0,
      weight: 5.0,
      isFemale: false,
      species: Species.dog,
    );

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Image.asset('assets/images/pummel.png', fit: BoxFit.cover),
        ),
        title: const Text("Pummel the Fish"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              _getAllPets();
              print("Fetching all pets from REST API");
            },
          ),
          // IconButton(
          //   onPressed: _getPetById,
          //   icon: const Icon(Icons.refresh),
          //   tooltip: "Fetch Pet by ID",
          // ),
          IconButton(
            onPressed: () {
              newPet;
              _addNewPet(newPet);
              print("Adding new pet: ${newPet.name}");
            },
            icon: const Icon(Icons.add),
            tooltip: "Add New Pet",
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<List<Pet>>(
            initialData: const [],
            future: pets,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return const PetListLoading();
                case ConnectionState.done:
                  if (snapshot.hasData) {
                    return PetListLoaded(pets: snapshot.data!);
                  } else {
                    return const PetListError(
                      errorMessage: "Fehler beim Abrufen der Haustiere",
                    );
                  }
              }
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
