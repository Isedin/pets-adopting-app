import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/widgets/pet_list_error.dart';
import 'package:pummel_the_fish/widgets/pet_list_loaded.dart';
import 'package:pummel_the_fish/widgets/pet_list_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirestorePetRepository firestorePetRepository;
  late Future<List<Pet>> pets;

  @override
  void initState() {
    super.initState();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
    );
    pets = _fetchPets();
  }

  Future<List<Pet>> _fetchPets() async {
    try {
      final petList = await firestorePetRepository.getAllPets();
      print("Fetched ${petList.length} pets from Firestore");
      return petList;
    } catch (e) {
      print("Error fetching pets from Firestore: $e");
      throw Exception("Fehler beim Abrufen der Haustiere");
    }
  }

  void _refreshPetList() {
    setState(() {
      pets = _fetchPets();
      print("Refreshing pet list");
    });
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
        onPressed: () async {
          await Navigator.pushNamed(context, "/create");
          print("Navigating to CreatePetScreen");
          _refreshPetList();
          print("Pet list refreshed after adding a new pet");
        },
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
