import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';

class DetailPetScreen extends StatefulWidget {
  final Pet pet;
  const DetailPetScreen({super.key, required this.pet});

  @override
  State<DetailPetScreen> createState() => _DetailPetScreenState();
}

class _DetailPetScreenState extends State<DetailPetScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return; // If the user popped the screen, do nothing.
          // If the user tries to pop, redirect them to the home screen
          // instead of going back to the previous screen.
        }
        print("Redirecting to home screen");
        Navigator.pushNamed(context, "/home");
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamed(context, "/home");
            },
          ),
          title: Text(widget.pet.name),
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Image.asset(
                    widget.pet.species == Species.dog
                        ? "assets/images/dog.png"
                        : widget.pet.species == Species.cat
                        ? "assets/images/cat.jpg"
                        : widget.pet.species == Species.fish
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
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 24,
                ),
                child: Column(
                  children: <Widget>[
                    _InfoCard(
                      labelText: "Name des Haustiers",
                      infoText: widget.pet.name,
                    ),
                    _InfoCard(
                      labelText: "Alter:",
                      infoText: "${widget.pet.age} Jahre",
                    ),
                    _InfoCard(
                      labelText: "Größe & Gewicht:",
                      infoText:
                          "${widget.pet.height} cm / ${widget.pet.weight} Gramm",
                    ),
                    _InfoCard(
                      labelText: "Geschlecht:",
                      infoText: widget.pet.isFemale == null
                          ? "Unbekannt"
                          : (widget.pet.isFemale! ? "Weiblich" : "Männlich"),
                    ),
                    _InfoCard(
                      labelText: "Spezies:",
                      infoText: widget.pet.species == Species.dog
                          ? "Hund"
                          : widget.pet.species == Species.cat
                          ? "Katze"
                          : widget.pet.species == Species.fish
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
  const _InfoCard({super.key, required this.labelText, required this.infoText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CustomColors.blueMedium,
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
