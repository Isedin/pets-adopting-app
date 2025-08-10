import 'dart:convert';

import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:http/http.dart' as http;
import 'package:pummel_the_fish/data/repositories/pet_repository.dart';
import 'dart:async';

const baseUrl = "https://losfluttern.de/pummelthefish/api";

class RestPetRepository implements PetRepository {
  final http.Client httpClient;

  RestPetRepository(this.httpClient);

  @override
  void addPet(Pet pet) {
    // TODO: implement addPet
    throw UnimplementedError();
  }

  @override
  void deletePetById(String id) {
    // TODO: implement deletePetById
    throw UnimplementedError();
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
    // TODO: Parse response.body to List<Pet>
    return [];
  }

  @override
  Pet? getPetById(String id) {
    // TODO: implement getPetById
    throw UnimplementedError();
  }

  @override
  void updatePetById(Pet pet) {
    // TODO: implement updatePet
  }
}
