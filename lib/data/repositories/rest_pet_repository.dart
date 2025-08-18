import 'dart:convert';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:http/http.dart' as http;
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'dart:async';

const baseUrl = "https://losfluttern.de/pummelthefish/api";

class RestPetRepository implements PetRepository {
  final http.Client httpClient;

  RestPetRepository({required this.httpClient});

  @override
  Future<void> addPet(Pet pet) async {
    final uri = Uri.parse('$baseUrl/pets');
    final response = await httpClient.post(
      uri,
      body: pet.toJson(),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      print("Kuscheltier erfolgreich hinzugefügt: ${pet.name}");
      return;
    } else {
      throw Exception(
        'Beim Hinzufügen des Kuscheltiers ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> deletePetById(String id) async {
    final uri = Uri.parse('$baseUrl/pets/$id');
    final response = await httpClient.delete(uri);

    if (response.statusCode == 204) {
      print("Kuscheltier mit ID $id erfolgreich gelöscht.");
    } else {
      throw Exception(
        'Beim Löschen des Kuscheltiers mit ID $id ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }

  @override
  Future<List<Pet>> getAllPets() async {
    final uri = Uri.parse('$baseUrl/pets');
    final response = await httpClient.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> dataList = jsonDecode(response.body);
      print(dataList);
      final petList = dataList.map((petMap) => Pet.fromMap(petMap)).toList();
      return petList;
    } else {
      throw Exception(
        'Beim Abrufen der Haustiere ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }

  @override
  Future<Pet?> getPetById(String id) async {
    final uri = Uri.parse('$baseUrl/pets/$id');
    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pet.fromMap(data);
    } else {
      throw Exception(
        'Beim Abrufen des Haustiers mit ID $id ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> updatePet(Pet pet) async {
    final uri = Uri.parse('$baseUrl/pets/${pet.id}');
    final response = await httpClient.put(
      uri,
      body: pet.toJson(),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Kuscheltier erfolgreich aktualisiert: ${pet.name}");
    } else {
      throw Exception(
        'Beim Aktualisieren des Kuscheltiers ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }
}
