import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class MyPetsRoute extends StatelessWidget {
  const MyPetsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<PetRepository>();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Pets')),
      body: StreamBuilder<List<Pet>>(
        stream: repo.watchAllPets(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final all = snap.data ?? const <Pet>[];
          final mine = (uid == null) ? <Pet>[] : all.where((p) => p.owner?.id == uid).toList();

          if (mine.isEmpty) {
            return const Center(child: Text("You haven't added any pets yet."));
          }
          return ListView.separated(
            itemCount: mine.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = mine[i];
              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(p.name),
                subtitle: Text(p.speciesCustom?.isNotEmpty == true
                    ? p.speciesCustom!
                    : p.species.displayName),
              );
            },
          );
        },
      ),
    );
  }
}
