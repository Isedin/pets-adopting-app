import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pummel_the_fish/bloc/create_pet_cubit.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/species/species_cubit.dart';
import 'package:pummel_the_fish/services/image_picker_service.dart';
import 'package:pummel_the_fish/widgets/custom_button.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/widgets/forms/disease_section.dart';
import 'package:pummel_the_fish/widgets/forms/gender_checkbox.dart';
import 'package:pummel_the_fish/widgets/forms/image_picker_field.dart';
import 'package:pummel_the_fish/widgets/forms/species_selector.dart';
import 'package:pummel_the_fish/widgets/forms/vaccination_section.dart';

class CreatePetScreen extends StatefulWidget {
  final Pet? petToEdit;
  const CreatePetScreen({super.key, this.petToEdit});

  @override
  State<CreatePetScreen> createState() => _CreatePetScreenState();
}

class _CreatePetScreenState extends State<CreatePetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _customSpeciesCtrl = TextEditingController();

  Species? _species;
  bool _isFemale = false;
  File? _pickedImage;
  bool _addAsNewSpecies = true;

  // vaccination / diseases
  bool _vaccinated = false;
  List<String> _vaccines = const [];
  bool _hasDiseases = false;
  List<String> _diseases = const [];

  final _picker = ImagePickerService();
  ScaffoldMessengerState? _scaffold;

  @override
  void initState() {
    super.initState();

    _customSpeciesCtrl.addListener(_onCustomSpeciesChanged);

    final p = widget.petToEdit;
    if (p != null) {
      _nameCtrl.text = p.name;
      _ageCtrl.text = p.age.toString();
      _heightCtrl.text = p.height.toString();
      _weightCtrl.text = p.weight.toString();
      _species = p.species;
      _customSpeciesCtrl.text = p.speciesCustom ?? '';
      _isFemale = p.isFemale ?? false;
      _vaccinated = p.vaccinated ?? false;
      _vaccines = List<String>.from(p.vaccines ?? const []);
      _hasDiseases = p.hasDiseases ?? false;
      _diseases = List<String>.from(p.diseases ?? const []);
    } else {
      _species = Species.fish; // default
    }
  }

  void _onCustomSpeciesChanged() {
    if (mounted) setState(() {}); // refresh UI while typing
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffold = ScaffoldMessenger.maybeOf(context);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _customSpeciesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(context);
    if (!mounted) return;
    setState(() => _pickedImage = file ?? _pickedImage);
  }

  String _normalizeKey(String label) {
    return label.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  Future<void> _maybeAddNewSpecies(String customLabel) async {
    try {
      final key = _normalizeKey(customLabel);
      await context.read<SpeciesCubit>().addIfMissing(key, customLabel);
    } catch (_) {
      // not critical if it fails
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text) ?? 0;
    final height = double.tryParse(_heightCtrl.text) ?? 0.0;
    final weight = double.tryParse(_weightCtrl.text) ?? 0.0;
    final speciesCustom =
        _species == Species.other ? _customSpeciesCtrl.text.trim() : null;

    if (_species == Species.other &&
        speciesCustom != null &&
        speciesCustom.isNotEmpty &&
        _addAsNewSpecies) {
      _maybeAddNewSpecies(speciesCustom);
    }

    if (widget.petToEdit != null) {
      context.read<CreatePetCubit>().updatePet(
            petToUpdate: widget.petToEdit!,
            name: name,
            species: _species!,
            speciesCustom: speciesCustom,
            age: age,
            height: height,
            weight: weight,
            isFemale: _isFemale,
            imageFile: _pickedImage,
            vaccinated: _vaccinated,
            vaccines: _vaccines,
            hasDiseases: _hasDiseases,
            diseases: _diseases,
          );
    } else {
      context.read<CreatePetCubit>().addPet(
            name: name,
            species: _species!,
            speciesCustom: speciesCustom,
            age: age,
            height: height,
            weight: weight,
            isFemale: _isFemale,
            imageFile: _pickedImage,
            vaccinated: _vaccinated,
            vaccines: _vaccines,
            hasDiseases: _hasDiseases,
            diseases: _diseases,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreatePetCubit, CreatePetState>(
      listener: (context, state) {
        if (!mounted) return;
        if (state is CreatePetSuccess) {
          _scaffold?.showSnackBar(
            SnackBar(
              content: Text(widget.petToEdit != null
                  ? "Haustier erfolgreich aktualisiert!"
                  : "Haustier erfolgreich gespeichert!"),
            ),
          );
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.of(context).pop();
          });
        } else if (state is CreatePetFailure) {
          _scaffold?.showSnackBar(
              SnackBar(content: Text("Fehler: ${state.error}")));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.petToEdit != null
              ? 'Kuscheltier bearbeiten'
              : 'Neues Tier anlegen'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                MediaQuery.of(context).orientation == Orientation.portrait
                    ? const EdgeInsets.all(24)
                    : EdgeInsets.symmetric(
                        horizontal:
                            MediaQuery.of(context).size.width / 5,
                        vertical: 40,
                      ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  ImagePickerField(
                    file: _pickedImage,
                    networkUrl: widget.petToEdit?.imageUrl,
                    onPick: _pickImage,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nameCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Name des Tieres'),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Bitte einen Namen eingeben!" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ageCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Alter des Tieres'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Bitte Alter eingeben!" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _heightCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Höhe des Tieres (cm)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Bitte die Höhe eingeben!" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Gewicht des Tieres (Gramm)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? "Bitte das Gewicht eingeben!" : null,
                  ),
                  const SizedBox(height: 16),

                  SpeciesSelector(
                    value: _species,
                    onChanged: (s) => setState(() => _species = s),
                    customController: _customSpeciesCtrl,
                  ),
                  CheckboxListTile(
                    title: const Text('Diese Tierart zur Filterliste hinzufügen'),
                    value: _addAsNewSpecies,
                    onChanged: (v) =>
                        setState(() => _addAsNewSpecies = v ?? false),
                  ),
                  const SizedBox(height: 12),

                  GenderCheckbox(
                      value: _isFemale,
                      onChanged: (v) => setState(() => _isFemale = v)),
                  const Divider(height: 32),

                  VaccinationSection(
                    vaccinated: _vaccinated,
                    vaccines: _vaccines,
                    onVaccinatedChanged: (v) =>
                        setState(() => _vaccinated = v),
                    onVaccinesChanged: (list) =>
                        setState(() => _vaccines = list),
                  ),
                  const Divider(height: 32),

                  DiseaseSection(
                    hasDiseases: _hasDiseases,
                    diseases: _diseases,
                    onHasDiseasesChanged: (v) =>
                        setState(() => _hasDiseases = v),
                    onDiseasesChanged: (list) =>
                        setState(() => _diseases = list),
                  ),
                  const SizedBox(height: 24),

                  BlocBuilder<CreatePetCubit, CreatePetState>(
                    builder: (context, state) {
                      final isLoading = state is CreatePetLoading;
                      return CustomButton(
                        onPressed: isLoading ? null : _onSave,
                        label: isLoading
                            ? 'Speichern...'
                            : (widget.petToEdit != null
                                ? "Aktualisieren"
                                : "Speichern"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
