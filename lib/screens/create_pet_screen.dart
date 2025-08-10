import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  bool currentIsFemale = false;
  String? currentName;
  int? currentAge;
  double? currentHeight;
  double? currentWeight;
  Species? currentSpecies;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Tier anlegen')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: MediaQuery.of(context).orientation == Orientation.portrait
              ? const EdgeInsets.all(24)
              : EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 5,
                  vertical: 40,
                ),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Name des Tieres',
                  ),
                  onChanged: (value) => currentName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte einen Namen eingeben!";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Alter des Tieres',
                  ),
                  onChanged: (value) => currentAge = int.tryParse(value),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte Alter eingeben!";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Höhe des Tieres',
                  ),
                  onChanged: (value) => currentHeight = double.tryParse(value),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte die Höhe eingeben!";
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Gewicht des Tieres (Gramm)',
                  ),
                  onChanged: (value) => currentWeight = double.tryParse(value),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Bitte das Gewicht eingeben!";
                    } else {
                      return null;
                    }
                  },
                ),
                DropdownButtonFormField<Species>(
                  hint: const Text('Tierart auswählen'),
                  items: const [
                    DropdownMenuItem(value: Species.dog, child: Text('Hund')),
                    DropdownMenuItem(value: Species.cat, child: Text('Katze')),
                    DropdownMenuItem(value: Species.fish, child: Text('Fisch')),
                    DropdownMenuItem(value: Species.bird, child: Text('Vogel')),
                  ],
                  onChanged: (Species? value) {
                    if (value != null) {
                      currentSpecies = value;
                    }
                  },
                  validator: (value) =>
                      value == null ? "Bitte eine Spezies eingeben!" : null,
                ),

                CheckboxListTile(
                  title: const Text('Weiblich?'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 16,
                  ),
                  value:
                      currentIsFemale, // This should be managed with a state variable
                  onChanged: (bool? value) {
                    if (value != null) {
                      print('Ist weiblich: $value');
                      setState(() {
                        currentIsFemale = value;
                      });
                    }
                  },
                ),
                CustomButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final pet = Pet(
                        id: "test",
                        name: currentName!,
                        species: currentSpecies!,
                        age: currentAge!,
                        weight: currentWeight!,
                        height: currentHeight!,
                        isFemale: currentIsFemale,
                      );
                      print("$pet");
                    }
                    Navigator.pushNamed(context, "/home");
                  },
                  label: "Speicher",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
