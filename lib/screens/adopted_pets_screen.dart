import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/screens/detail_pet_screen.dart';

class AdoptedPetsScreen extends StatelessWidget {
  final List<Pet> adoptedPets;
  const AdoptedPetsScreen({super.key, required this.adoptedPets});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adopted Pets')),

      body: adoptedPets.isEmpty
          ? const Center(child: Text('No adopted pets'))
          : ListView.builder(
              itemCount: adoptedPets.length,
              itemBuilder: (context, index) {
                final pet = adoptedPets[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(pet.imageUrl!),
                  ),
                  title: Text(pet.name),
                  subtitle: Text(pet.species.toString()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPetScreen(pet: pet),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
