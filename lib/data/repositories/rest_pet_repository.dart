import 'dart:convert';
import 'dart:io';

import 'package:pummel_the_fish/data/mappers/pet_rest_mapper.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:http/http.dart' as http;
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'dart:async';

const baseUrl = "https://losfluttern.de/pummelthefish/api";

class RestPetRepository implements PetRepository {
  final http.Client httpClient;

  RestPetRepository({required this.httpClient});

  @override
  Future<void> addPet(Pet pet, {File? imageFile}) async {
    final uri = Uri.parse('$baseUrl/pets');
    final response = await httpClient.post(
      uri,
      body: jsonEncode(PetRestMapper.toJson(pet)),
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
    if (response.statusCode != 200) {
      throw Exception('Error fetching pets: ${response.statusCode}');
    }
    final List<dynamic> dataList = jsonDecode(response.body);
    return dataList
        .map((m) => PetRestMapper.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  @override
  Stream<Pet?> watchPet(String id) async* {
    final uri = Uri.parse('$baseUrl/pets/$id');
    final response = await httpClient.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        yield PetRestMapper.fromJson(data);
      } else {
        throw Exception(
          'Unexpected payload for GET /pets/$id: ${response.body}',
        );
      }
    } else if (response.statusCode == 404) {
      yield null; // Pet not found
    } else {
      throw Exception(
        'Beim Abrufen des Haustiers mit ID $id ist ein Fehler aufgetreten: ${response.statusCode}',
      );
    }
  }

  @override
  Future<void> updatePet(Pet pet, {String? id, File? imageFile}) async {
    final petId = id ?? pet.id;
    final uri = Uri.parse('$baseUrl/pets/$petId');
    final response = await httpClient.put(
      uri,
      body: jsonEncode(PetRestMapper.toJson(pet)),
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

  @override
  Future<bool> adoptPet(String petId) {
    // TODO: implement adoptPet
    throw UnimplementedError();
  }

  @override
  Future<void> unadoptPet(String petId) {
    // TODO: implement unadoptPet
    throw UnimplementedError();
  }

  @override
  Stream<List<Pet>> watchAdoptedPets() {
    // TODO: implement watchAdoptedPets
    throw UnimplementedError();
  }

  @override
  Stream<List<Pet>> watchAllPets() {
    // TODO: implement watchAllPets
    throw UnimplementedError();
  }

  @override
  Stream<bool> watchIsAdopted(String petId) {
    // TODO: implement watchIsAdopted
    throw UnimplementedError();
  }
}
