import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/create_pet_route.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/widgets/inherited_adoption_bag.dart';

class DetailPetScreen extends StatefulWidget {
  final Pet pet;
  @visibleForTesting
  final FirestorePetRepository? firestorePetRepository;

  const DetailPetScreen({
    super.key,
    required this.pet,
    this.firestorePetRepository,
  });

  @override
  State<DetailPetScreen> createState() => _DetailPetScreenState();
}

class _DetailPetScreenState extends State<DetailPetScreen> {
  late final FirestorePetRepository firestorePetRepository;

  @override
  void initState() {
    super.initState();
    firestorePetRepository =
        widget.firestorePetRepository ??
        FirestorePetRepository(
          firestore: FirebaseFirestore.instance,
          storage: FirebaseStorage.instance,
        );
  }

  void _onDeletePet(String id) {
    try {
      firestorePetRepository.deletePetById(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Haustier erfolgreich gelöscht!")),
      );
      Navigator.of(
        context,
      ).pop(true); // Pop the screen and return true to indicate deletion
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fehler beim Löschen des Haustiers: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Pet?>(
      stream: firestorePetRepository.getPetById(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pet = snapshot.data;

        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text("Das Kuscheltier ist nicht mehr vorhanden."),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop(false);
                print("Redirecting to home screen");
              },
            ),
            actions: [
              IconButton(
                onPressed: () => _onDeletePet(pet.id),
                icon: const Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePetRoute(
                        petToEdit: pet,
                        repo: firestorePetRepository,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
              ),
            ],
            title: Text(pet.name),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                          ? Image.network(
                              pet.imageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 240,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset("assets/images/fish.jpg");
                              },
                            )
                          : Image.asset(
                              pet.species == Species.dog
                                  ? "assets/images/dog.png"
                                  : pet.species == Species.cat
                                  ? "assets/images/cat.jpg"
                                  : pet.species == Species.fish
                                  ? "assets/images/fish.jpg"
                                  : "assets/images/bird.jpg",
                            ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 40,
                          color: CustomColors.orangeTransparent,
                          child: Center(
                            child: Text(
                              "Adoptier mich!",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 40,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: <Widget>[
                        _InfoCard(
                          labelText: "Name des Haustiers",
                          infoText: pet.name,
                        ),
                        _InfoCard(
                          labelText: "Alter:",
                          infoText: "${pet.age} Jahre",
                        ),
                        _InfoCard(
                          labelText: "Größe & Gewicht:",
                          infoText: "${pet.height} cm / ${pet.weight} Gramm",
                        ),
                        _InfoCard(
                          labelText: "Geschlecht:",
                          infoText: pet.isFemale == null
                              ? "Unbekannt"
                              : (pet.isFemale! ? "Weiblich" : "Männlich"),
                        ),
                        _InfoCard(
                          labelText: "Spezies:",
                          infoText: pet.species == Species.dog
                              ? "Hund"
                              : pet.species == Species.cat
                              ? "Katze"
                              : pet.species == Species.fish
                              ? "Fisch"
                              : "Vogel",
                        ),
                        Row(
                          children: [
                            CustomButton(
                              onPressed: () {
                                final bag = InheritedAdoptionBag.of(context);
                                if (bag != null) {
                                  bag.addPet();
                                }
                              },
                              label: "Adoptieren",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String labelText;
  final String infoText;
  const _InfoCard({required this.labelText, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.blueMedium,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(labelText, style: Theme.of(context).textTheme.bodyMedium),
            Text(infoText, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
