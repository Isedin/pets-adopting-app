import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/manage_pets_cubit.dart';
import 'package:pummel_the_fish/screens/adopted_pets_screen.dart';
import 'package:pummel_the_fish/screens/detail_pet_screen.dart';
import 'package:pummel_the_fish/widgets/pet_card.dart';
import 'package:pummel_the_fish/widgets/search_bar.dart';
import 'package:pummel_the_fish/widgets/modern_bottom_bar.dart';
import 'package:pummel_the_fish/widgets/pet_list_error.dart';
import 'package:pummel_the_fish/widgets/pet_list_loading.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/widgets/chipses/species_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  Species? _selectedSpecies; // null = “Alle”
  int _selectedIndex = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) => setState(() => _selectedIndex = index);

  List<Pet> _applyFilter(List<Pet> pets) {
    final q = _searchCtrl.text.trim().toLowerCase();
    return pets.where((p) {
      final speciesLabel = p.species == Species.other
          ? (p.speciesCustom ?? '')
          : p.species.displayName;

      final byText =
          q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          speciesLabel.toLowerCase().contains(q);

      final byChip = _selectedSpecies == null || p.species == _selectedSpecies;

      return byText && byChip;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManagePetsCubit(context.read<PetRepository>()),
      child: BlocBuilder<ManagePetsCubit, ManagePetsState>(
        builder: (context, state) {
          final adoptedCount = state.adoptedPets.length;
          final allPets = state.pets;
          final filtered = _applyFilter(allPets);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Pet Adoption App'),
              centerTitle: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Image.asset('assets/images/pummel.png'),
              ),
            ),
            body: IndexedStack(
              index: _selectedIndex,
              children: [
                // Tab 0: All pets + filter
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      children: [
                        AppSearchBar(
                          controller: _searchCtrl,
                          hintText: 'Suche nach Name oder Art…',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 8),
                        SpeciesChips(
                          selected: _selectedSpecies,
                          onSelected: (s) =>
                              setState(() => _selectedSpecies = s),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: switch (state.status) {
                            ManagePetsStatus.initial => const PetListError(
                              errorMessage:
                                  'Keine Kuscheltiere zur Adoption freigegeben',
                            ),
                            ManagePetsStatus.loading => const PetListLoading(),
                            ManagePetsStatus.error => const PetListError(
                              errorMessage:
                                  'Fehler beim Laden der Kuscheltiere',
                            ),
                            ManagePetsStatus.success =>
                              filtered.isEmpty
                                  ? const Center(
                                      child: Text('Keine Ergebnisse'),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: .78,
                                          ),
                                      itemCount: filtered.length,
                                      itemBuilder: (_, i) => PetCard(
                                        pet: filtered[i],
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetailPetScreen(
                                              pet: filtered[i],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab 1: Adopted
                SafeArea(
                  child: state.status == ManagePetsStatus.loading
                      ? const PetListLoading()
                      : AdoptedPetsScreen(adoptedPets: state.adoptedPets),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, "/create"),
              child: const Icon(Icons.add),
            ),
            bottomNavigationBar: ModernBottomBar(
              currentIndex: _selectedIndex,
              adoptedCount: adoptedCount,
              onTap: _onNavTap,
            ),
          );
        },
      ),
    );
  }
}
