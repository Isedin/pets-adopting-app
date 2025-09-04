import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/manage_pets_cubit.dart';
import 'package:pummel_the_fish/screens/adopted_pets_screen.dart';
import 'package:pummel_the_fish/widgets/adoption_bottom_nav_bar.dart';
import 'package:pummel_the_fish/widgets/pet_list_error.dart';
import 'package:pummel_the_fish/widgets/pet_list_loaded.dart';
import 'package:pummel_the_fish/widgets/pet_list_loading.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ManagePetsCubit(context.read<FirestorePetRepository>()),
      child: StreamBuilder(
        stream: context
            .read<FirestorePetRepository>()
            .getAdoptionCountAsStream(),
        builder: (context, snapshot) {
          final adoptionCount = context
              .watch<ManagePetsCubit>()
              .state
              .adoptedPets
              .length;

          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  'assets/images/pummel.png',
                  fit: BoxFit.cover,
                ),
              ),
              title: const Text("Pet Adoption App"),
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                // The first screen (all pets)
                Builder(
                  builder: (context) {
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: BlocConsumer<ManagePetsCubit, ManagePetsState>(
                          listener: (context, state) {
                            if (state.status == ManagePetsStatus.error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Fehler beim Abrufen der Haustiere",
                                  ),
                                ),
                              );
                            }
                          },
                          builder: (context, state) {
                            switch (state.status) {
                              case ManagePetsStatus.initial:
                                return const PetListError(
                                  errorMessage:
                                      "Keine Kuscheltiere zur Adoption freigegeben",
                                );
                              case ManagePetsStatus.loading:
                                return const PetListLoading();
                              case ManagePetsStatus.success:
                                return PetListLoaded(pets: state.pets);
                              case ManagePetsStatus.error:
                                return const PetListError(
                                  errorMessage:
                                      "Fehler beim Laden der Kuscheltiere",
                                );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                // The second screen (adopted pets)
                BlocBuilder<ManagePetsCubit, ManagePetsState>(
                  builder: (context, state) {
                    if (state.status == ManagePetsStatus.loading) {
                      return const PetListLoading();
                    } else if (state.status == ManagePetsStatus.success) {
                      return AdoptedPetsScreen(adoptedPets: state.adoptedPets);
                    }
                    return const PetListError(
                      errorMessage: 'Nema usvojenih ljubimaca.',
                    );
                  },
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/create");
              },
              tooltip: 'add',
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: AdoptionBottomNavBar(
              petCount: adoptionCount,
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
            ),
          );
        },
      ),
    );
  }
}
