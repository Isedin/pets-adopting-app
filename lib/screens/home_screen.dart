import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
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
      create: (context) => ManagePetsCubit(context.read<PetRepository>()),
      child: BlocBuilder<ManagePetsCubit, ManagePetsState>(
        builder: (context, state) {
          final adoptionCount = state.adoptedPets.length;

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
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: switch (state.status) {
                      ManagePetsStatus.initial => const PetListError(
                        errorMessage:
                            "Keine Kuscheltiere zur Adoption freigegeben",
                      ),
                      ManagePetsStatus.loading => const PetListLoading(),
                      ManagePetsStatus.success => PetListLoaded(
                        pets: state.pets,
                      ),
                      ManagePetsStatus.error => const PetListError(
                        errorMessage: "Fehler beim Laden der Kuscheltiere",
                      ),
                    },
                  ),
                ),
                // Adopted pets
                state.status == ManagePetsStatus.loading
                    ? const PetListLoading()
                    : AdoptedPetsScreen(adoptedPets: state.adoptedPets),
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
