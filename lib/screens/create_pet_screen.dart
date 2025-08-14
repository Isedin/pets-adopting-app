import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';

class CreatePetScreen extends StatefulWidget {
  final Pet? petToEdit;
  const CreatePetScreen({super.key, this.petToEdit});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  Species? _species;
  bool _isFemale = false;
  late final FirestorePetRepository firestorePetRepository;

  @override
  void initState() {
    super.initState();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
    );
    if (widget.petToEdit != null) {
      _nameController.text = widget.petToEdit!.name;
      _ageController.text = widget.petToEdit!.age.toString();
      _heightController.text = widget.petToEdit!.height.toString();
      _weightController.text = widget.petToEdit!.weight.toString();
      _species = widget.petToEdit!.species;
      _isFemale = widget.petToEdit!.isFemale ?? false;
    } else {
      _species = Species.fish; // Default species if not editing
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final name = _nameController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final species = _species ?? Species.fish;
      final isFemale = _isFemale;
      final Pet pet = Pet(
        id: widget.petToEdit?.id ?? '',
        name: name,
        species: species,
        age: age,
        height: height,
        weight: weight,
        isFemale: isFemale,
      );

      try {
        if (widget.petToEdit != null) {
          await firestorePetRepository.updatePet(pet);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Haustier erfolgreich aktualisiert!")),
          );
        } else {
          await firestorePetRepository.addPet(pet);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Haustier erfolgreich gespeichert!")),
          );
        }
        if (!mounted) return;
        Navigator.of(context).pop(pet);
      } on Exception catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler beim Speichern des Haustiers: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.petToEdit != null
              ? 'Kuscheltier bearbeiten'
              : 'Neues Tier anlegen',
        ),
      ),
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
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name des Tieres',
                  ),
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
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Alter des Tieres',
                  ),
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
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Höhe des Tieres',
                  ),
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
                  controller: _weightController,
                  decoration: const InputDecoration(
                    labelText: 'Gewicht des Tieres (Gramm)',
                  ),
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
                      setState(() {
                        _species = value;
                        print('Selected species: $_species');
                      });
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
                      _isFemale, // This should be managed with a state variable
                  activeColor: CustomColors.blueMedium,
                  side: const BorderSide(color: CustomColors.blueDark),
                  onChanged: (bool? value) {
                    if (value != null) {
                      print('Ist weiblich: $value');
                      setState(() {
                        _isFemale = value;
                      });
                    }
                  },
                ),
                CustomButton(
                  onPressed: () {
                    _onSave();
                  },
                  label: widget.petToEdit != null
                      ? "Aktualisieren"
                      : "Speichern",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
