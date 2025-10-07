
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/screens/adopted_pets_screen.dart';
class AdoptedPetsRoute extends StatelessWidget {
  const AdoptedPetsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PetRepository>();
    return StreamBuilder<List<Pet>>(
      stream: repo.watchAdoptedPets(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snap.error}')));
        }
        final adopted = snap.data ?? const <Pet>[];
        return AdoptedPetsScreen(adoptedPets: adopted);
      },
    );
  }
}