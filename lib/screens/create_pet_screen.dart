import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';

class CreatePetScreen extends StatefulWidget {
  const CreatePetScreen({super.key});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  late final FirestorePetRepository firestorePetRepository;
  @override
  void initState() {
    super.initState();
    // final httpClient = http.Client();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
    );
  }

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
                  hint: Text(
                    'Tierart auswählen',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  items: [
                    // Icon(FontAwesome.fish, color: CustomColors.blueMedium,)
                    DropdownMenuItem(
                      value: Species.dog,
                      child: Text(
                        'Hund',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.blueDark,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: Species.cat,
                      child: Text(
                        'Katze',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.blueDark,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: Species.fish,
                      child: Text(
                        'Fisch',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.blueDark,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: Species.bird,
                      child: Text(
                        'Vogel',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: CustomColors.blueDark,
                        ),
                      ),
                    ),
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
                  title: Text(
                    'Weiblich?',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 16,
                  ),
                  value:
                      currentIsFemale, // This should be managed with a state variable
                  activeColor: CustomColors.blueMedium,
                  side: const BorderSide(color: CustomColors.blueDark),
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
                    _addPet();
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

  Future<void> _addPet() async {
    if (_formKey.currentState?.validate() ?? false) {
      final pet = Pet(
        id: '',
        name: currentName!,
        species: currentSpecies!,
        age: currentAge!,
        weight: currentWeight!,
        height: currentHeight!,
        isFemale: currentIsFemale,
      );
      try {
        await firestorePetRepository.addPet(pet);
        print("New pet added: ${pet.name}");
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: CustomColors.blueDark,
            content: Text("Kuscheltier erfolgreich angelegt!"),
          ),
        );
      } on Exception {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: CustomColors.red,
            content: Text("Fehler beim Anlegen des Kuscheltiers!"),
          ),
        );
      }
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
}
