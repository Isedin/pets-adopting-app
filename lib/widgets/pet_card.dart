// lib/widgets/pet_card.dart
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onTap;
  const PetCard({super.key, required this.pet, this.onTap});

  @override
  Widget build(BuildContext context) {
    final speciesAsset = switch (pet.species) {
      Species.dog => "assets/images/dog.png",
      Species.cat => "assets/images/cat.jpg",
      Species.fish => "assets/images/fish.jpg",
      Species.bird => "assets/images/bird.jpg",
      Species.other => "assets/images/fish.jpg", // fallback
    };

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: (pet.imageUrl != null && pet.imageUrl!.isNotEmpty)
                  ? Image.network(pet.imageUrl!, fit: BoxFit.cover)
                  : Image.asset(speciesAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pet.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.age} Jahre • ${pet.species.displayName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
