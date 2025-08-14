import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/screens/create_pet_screen.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

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
  late Pet pet;

  bool _hasBeenEdited = false;

  @override
  void initState() {
    super.initState();
    pet = widget.pet;
    firestorePetRepository =
        widget.firestorePetRepository ??
        FirestorePetRepository(firestore: FirebaseFirestore.instance);
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(_hasBeenEdited);
            print("Redirecting to home screen");
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _onDeletePet(pet.id),
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () async {
              final updatedPet = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreatePetScreen(petToEdit: pet),
                ),
              );

              if (updatedPet is Pet) {
                setState(() {
                  pet = updatedPet;
                  _hasBeenEdited = true;
                });
              }
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
                  Image.asset(
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
