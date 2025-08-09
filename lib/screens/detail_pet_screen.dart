import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';

class DetailPetScreen extends StatelessWidget {
  final Pet pet;
  const DetailPetScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: SafeArea(
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
                    color: const Color(0x88FFC942),
                    child: const Center(
                      child: Text(
                        "Adoptier mich!",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Column(
                children: <Widget>[
                  _InfoCard(
                    labelText: "Name des Haustiers",
                    infoText: pet.name,
                  ),
                  _InfoCard(labelText: "Alter:", infoText: "${pet.age} Jahre"),
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String labelText;
  final String infoText;
  const _InfoCard({super.key, required this.labelText, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[Text(labelText), Text(infoText)],
        ),
      ),
    );
  }
}
