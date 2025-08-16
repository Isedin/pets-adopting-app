import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/manage_pets_cubit.dart';
import 'package:pummel_the_fish/widgets/adoption_bag.dart';
import 'package:pummel_the_fish/widgets/inherited_adoption_bag.dart';
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
  late Stream<List<Pet>> petStream;
  int petCount = 0;

  @override
  void initState() {
    super.initState();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ManagePetsCubit(firestorePetRepository)..getAllPets(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'assets/images/pummel.png',
                  fit: BoxFit.cover,
                ),
              ),
              title: const Text("Pummel the Fish"),
              actions: [
                AdoptionBag(
                  petCount: InheritedAdoptionBag.of(context)?.petCount ?? 0,
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<ManagePetsCubit, ManagePetsState>(
                  builder: (context, state) {
                    if (state is ManagePetsInitial) {
                      return const PetListError(
                        errorMessage:
                            "Keine Kuscheltiere zur Adoption freigeben",
                      );
                    } else if (state is ManagePetsLoading) {
                      return const PetListLoading();
                    } else if (state is ManagePetsSuccess) {
                      return PetListLoaded(pets: state.pets);
                    } else {
                      return const PetListError(
                        errorMessage: "Fehler beim Abrufen der Haustiere",
                      );
                    }
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/create");
              },
              tooltip: 'add',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
