import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/bloc/create_pet_cubit.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/data/repositories/species_repository.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/species/species_cubit.dart';
import 'package:pummel_the_fish/screens/create_pet_screen.dart';

class CreatePetRoute extends StatelessWidget {
  final Pet? petToEdit;
  final FirestorePetRepository repo;
  const CreatePetRoute({super.key, this.petToEdit, required this.repo});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: repo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => CreatePetCubit(petRepository: repo)),
          BlocProvider(
            create: (ctx) => SpeciesCubit(
              ctx
                  .read<
                    SpeciesRepository
                  >(), // <— koristi SpeciesRepository iz main.dart
            ),
          ),
        ],
        child: CreatePetScreen(petToEdit: petToEdit),
      ),
    );
  }
}
