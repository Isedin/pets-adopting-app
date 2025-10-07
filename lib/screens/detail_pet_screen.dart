import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/services/chat_navigator.dart';
import 'package:pummel_the_fish/theme/custom_colors.dart';
import 'package:pummel_the_fish/widgets/create_pet_route.dart';
import 'package:pummel_the_fish/widgets/species_badge.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/widgets/auth_required_dialog.dart'; // <= dialog za login/register

class DetailPetScreen extends StatefulWidget {
  final Pet pet;
  final FirestorePetRepository? firestorePetRepository;
  final bool openedFromAdopted;

  const DetailPetScreen({
    super.key,
    required this.pet,
    this.firestorePetRepository,
    this.openedFromAdopted = false,
  });

  @override
  State<DetailPetScreen> createState() => _DetailPetScreenState();
}

class _DetailPetScreenState extends State<DetailPetScreen> {
  late final FirestorePetRepository repo;
  bool _adopting = false;
  ScaffoldMessengerState? _scaffold;

  @override
  void initState() {
    super.initState();
    repo =
        widget.firestorePetRepository ??
        FirestorePetRepository(
          firestore: FirebaseFirestore.instance,
          storage: FirebaseStorage.instance,
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffold = ScaffoldMessenger.maybeOf(context);
  }

  Future<void> _onDeletePet(String id) async {
    try {
      await repo.deletePetById(id);
      if (!mounted) return;
      _scaffold?.showSnackBar(
        const SnackBar(content: Text("Haustier erfolgreich gelöscht!")),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    } catch (e) {
      if (!mounted) return;
      _scaffold?.showSnackBar(
        SnackBar(content: Text("Fehler beim Löschen des Haustiers: $e")),
      );
    }
  }

  String _assetForSpecies(Species s) {
    switch (s) {
      case Species.dog:
        return "assets/images/dog.png";
      case Species.cat:
        return "assets/images/cat.jpg";
      case Species.fish:
        return "assets/images/fish.jpg";
      case Species.bird:
        return "assets/images/bird.jpg";
      case Species.other:
        return "assets/images/fish.jpg"; // fallback/placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Pet?>(
      stream: repo.watchPet(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              title: const Text('Fehler'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final pet = snapshot.data;
        if (pet == null) {
          return const Scaffold(
            body: Center(
              child: Text("Das Kuscheltier ist nicht mehr vorhanden."),
            ),
          );
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        final isOwner = uid != null && pet.ownerIdOrNull == uid;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            title: Text(pet.name),
            actions: [
              // Edit/Delete for only owner
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    if (widget.openedFromAdopted) {
                      try {
                        await repo.unadoptPet(pet.id);
                        if (!mounted) return;
                        _scaffold?.showSnackBar(
                          const SnackBar(
                            content: Text("Aus 'Adopted' entfernt."),
                          ),
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) Navigator.of(context).pop(true);
                        });
                      } catch (e) {
                        if (!mounted) return;
                        _scaffold?.showSnackBar(
                          SnackBar(content: Text("Fehler beim Entfernen: $e")),
                        );
                      }
                    } else {
                      await _onDeletePet(pet.id);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CreatePetRoute(petToEdit: pet, repo: repo),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // hero image
                  Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 240,
                        child: pet.imageUrl != null && pet.imageUrl!.isNotEmpty
                            ? Image.network(
                                pet.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  _assetForSpecies(pet.species),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Image.asset(
                                _assetForSpecies(pet.species),
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 40,
                          color: CustomColors.orangeTransparent,
                          alignment: Alignment.center,
                          child: Text(
                            "Adoptier mich!",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SpeciesBadge(
                          species: pet.species,
                          customLabel: pet.speciesCustom,
                          size: 20,
                        ),
                        const SizedBox(height: 12),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Spezies"),
                          subtitle: Text(
                            (pet.species == Species.other &&
                                    (pet.speciesCustom?.trim().isNotEmpty ??
                                        false))
                                ? pet.speciesCustom!
                                : pet.species.displayName,
                          ),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Alter"),
                          subtitle: Text("${pet.age} Jahre"),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Größe & Gewicht"),
                          subtitle: Text("${pet.height} cm / ${pet.weight} g"),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Geschlecht"),
                          subtitle: Text(
                            pet.isFemale == null
                                ? "Unbekannt"
                                : (pet.isFemale! ? "Weiblich" : "Männlich"),
                          ),
                        ),

                        const Divider(height: 24),

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Geimpft"),
                          subtitle: Text(
                            (pet.vaccinated ?? false) ? "Ja" : "Nein",
                          ),
                        ),
                        if (pet.vaccinated == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Impfungen",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if ((pet.vaccines?.isNotEmpty ?? false))
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: pet.vaccines!
                                  .map((v) => Chip(label: Text(v)))
                                  .toList(),
                            )
                          else
                            const Text("Keine Impfungen hinterlegt."),
                          const SizedBox(height: 16),
                        ],

                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Hat ein Leiden / Krankheit"),
                          subtitle: Text(
                            (pet.hasDiseases ?? false) ? "Ja" : "Nein",
                          ),
                        ),
                        if (pet.hasDiseases == true) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Krankheiten",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if ((pet.diseases?.isNotEmpty ?? false))
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: pet.diseases!
                                  .map((d) => Chip(label: Text(d)))
                                  .toList(),
                            )
                          else
                            const Text("Keine Krankheiten hinterlegt."),
                          const SizedBox(height: 8),
                        ],

                        const SizedBox(height: 12),

                        // Adopt button / already adopted
                        Row(
                          children: [
                            StreamBuilder<bool>(
                              stream: repo.watchIsAdopted(pet.id),
                              builder: (context, s) {
                                final already = s.data ?? false;

                                if (already) {
                                  return ElevatedButton(
                                    onPressed: null,
                                    child: const Text("Bereits adoptiert"),
                                  );
                                }

                                return ElevatedButton(
                                  onPressed: _adopting
                                      ? null
                                      : () async {
                                          final user =
                                              FirebaseAuth.instance.currentUser;

                                          // Guest? dialog for login/register
                                          if (user == null ||
                                              user.isAnonymous) {
                                            await showAuthRequiredDialog(
                                              context,
                                            );
                                            return;
                                          }

                                          // Not verified? Ponudi resend
                                          if (!user.emailVerified) {
                                            if (!mounted) return;
                                            final sb = ScaffoldMessenger.of(
                                              context,
                                            );
                                            sb.showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  'Bitte E-Mail verifizieren, um zu adoptieren.',
                                                ),
                                                action: SnackBarAction(
                                                  label: 'Link senden',
                                                  onPressed: () async {
                                                    try {
                                                      // (optional) localize template
                                                      // await FirebaseAuth.instance.setLanguageCode('de');
                                                      await user
                                                          .sendEmailVerification();
                                                      sb.showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Verifizierungslink gesendet.',
                                                          ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      sb.showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Fehler beim Senden: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            );
                                            return;
                                          }

                                          if (pet.ownerIdOrNull == user.uid) {
                                            if (!mounted) return;
                                            _scaffold?.showSnackBar(
                                              const SnackBar(content: Text('You cannot adopt your own pet.')),
                                            );
                                            return;
                                          }

                                          setState(() => _adopting = true);
                                          try {
                                            final ok = await repo.adoptPet(
                                              pet.id,
                                            );
                                            if (!mounted) return;
                                            _scaffold?.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  ok
                                                      ? 'Haustier adoptiert!'
                                                      : 'Dieses Haustier ist bereits adoptiert.',
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            if (!mounted) return;
                                            _scaffold?.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Fehler bei der Adoption: $e',
                                                ),
                                              ),
                                            );
                                          } finally {
                                            if (mounted) {
                                              setState(() => _adopting = false);
                                            }
                                          }
                                        },
                                  child: Text(
                                    _adopting
                                        ? 'Wird adoptiert...'
                                        : 'Adoptieren',
                                  ),
                                );
                              },
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.message),
                              label: const Text('Nachricht senden'),
                              onPressed: () => ChatNavigator.openWith(context, pet.ownerIdOrNull),
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
