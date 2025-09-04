import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/widgets/inherited_adoption_bag.dart';

class AdoptionBagWrapper extends StatefulWidget {
  final Widget child;
  const AdoptionBagWrapper({super.key, required this.child});

  @override
  State<AdoptionBagWrapper> createState() => _AdoptionBagWrapperState();
}

class _AdoptionBagWrapperState extends State<AdoptionBagWrapper> {
  late final FirestorePetRepository firestorePetRepository;
  @override
  void initState() {
    super.initState();
    firestorePetRepository = FirestorePetRepository(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: firestorePetRepository.getAdoptionCountAsStream(),
      initialData: 0,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Fehler beim Laden der Adoptionsanzahl: ${snapshot.error}",
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return InheritedAdoptionBag(
          petCount: snapshot.data ?? 0,
          addPet: () => firestorePetRepository.incrementAdoptionCount(),
          child: widget.child,
        );
      },
    );
  }
}
