import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pummel_the_fish/bloc/create_pet_cubit.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

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
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
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

  Future<void> _pickImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text("Chose your Photo source"),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
              child: const Text("Camera"),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
              child: const Text("Gallerry"),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _pickedImage = File(pickedFile.path);
        });
      }
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final name = _nameController.text;
      final age = int.tryParse(_ageController.text) ?? 0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final weight = double.tryParse(_weightController.text) ?? 0.0;
      final isFemale = _isFemale;

      if (widget.petToEdit != null) {
        context.read<CreatePetCubit>().updatePet(
          petToUpdate: widget.petToEdit!,
          name: name,
          species: _species ?? widget.petToEdit!.species,
          age: age,
          height: height,
          weight: weight,
          isFemale: isFemale,
          imageFile: _pickedImage,
        );
      } else {
        context.read<CreatePetCubit>().addPet(
          name: name,
          species: _species!,
          age: age,
          height: height,
          weight: weight,
          isFemale: isFemale,
          imageFile: _pickedImage,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreatePetCubit(
        petRepository: FirestorePetRepository(
          firestore: FirebaseFirestore.instance,
          storage: FirebaseStorage.instance,
        ),
      ),
      child: BlocListener<CreatePetCubit, CreatePetState>(
        listener: (context, state) {
          if (state is CreatePetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.petToEdit != null
                      ? "Haustier erfolgreich aktualisiert!"
                      : "Haustier erfolgreich gespeichert!",
                ),
              ),
            );
            Navigator.of(context).pop();
          } else if (state is CreatePetFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Fehler: ${state.error}")));
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.petToEdit != null
                  ? 'Kuscheltier bearbeiten'
                  : 'Neues Tier anlegen',
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding:
                  MediaQuery.of(context).orientation == Orientation.portrait
                  ? const EdgeInsets.all(24)
                  : EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 5,
                      vertical: 40,
                    ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    if (_pickedImage != null)
                      Image.file(_pickedImage!, height: 200, fit: BoxFit.cover)
                    else if (widget.petToEdit != null &&
                        widget.petToEdit!.imageUrl != null)
                      Image.network(
                        widget.petToEdit!.imageUrl!,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<Species>(
                      hint: Text(
                        'Tierart auswählen',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      value: _species,
                      items: Species.values.map((Species species) {
                        return DropdownMenuItem<Species>(
                          value: species,
                          child: Text(
                            species.displayName,
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(color: CustomColors.blueDark),
                          ),
                        );
                      }).toList(),
                      onChanged: (Species? value) {
                        if (value != null) {
                          setState(() {
                            _species = value;
                          });
                        }
                      },
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Bild auswählen'),
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
                      value: _isFemale,
                      activeColor: CustomColors.blueMedium,
                      side: const BorderSide(color: CustomColors.blueDark),
                      onChanged: (bool? value) {
                        if (value != null) {
                          setState(() {
                            _isFemale = value;
                          });
                        }
                      },
                    ),
                    CustomButton(
                      onPressed: _onSave,
                      label: widget.petToEdit != null
                          ? "Aktualisieren"
                          : "Speichern",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
