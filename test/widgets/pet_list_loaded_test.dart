import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';
import 'package:pummel_the_fish/widgets/pet_list_loaded.dart';

void main() {
  testWidgets('should display all given Pets', (tester) async {
    final List<Pet> tPets = [
      Pet(
        id: "1",
        name: "Kira",
        species: Species.dog,
        age: 10,
        weight: 250.0,
        height: 20.0,
        isFemale: true,
      ),
      Pet(
        id: "2",
        name: "Space",
        species: Species.fish,
        age: 3,
        weight: 400.0,
        height: 40.0,
        isFemale: false,
      ),
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PetListLoaded(pets: tPets)),
      ),
    );

    expect(find.text("Kira"), findsOneWidget);
    expect(find.text("Space"), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byIcon(Icons.female), findsNWidgets(1));
    expect(find.byIcon(Icons.male), findsNWidgets(1));
    expect(find.byKey(const ValueKey("pet-1")), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('pet_list_loaded.png'),
    );
  });
}
