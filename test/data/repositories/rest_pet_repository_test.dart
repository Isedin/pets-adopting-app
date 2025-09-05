import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/rest_pet_repository.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late RestPetRepository restPetRepository;

  late String tPetsJson;
  late String tPetJson;
  late List<Pet> tPetList;
  late Pet tPet;

  setUpAll(() {
    registerFallbackValue(Uri.parse("$baseUrl/pets"));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    restPetRepository = RestPetRepository(httpClient: mockHttpClient);

    tPetsJson = '''[
  {
    "id": "1",
    "name": "Kira",
    "species": 0,
    "weight": 250.0,
    "height": 20.0,
    "age": 10,
    "isFemale": true,
    "owner": null
    },
    {
    "id": "2",
    "name": "Harribart",
    "species": 3,
    "weight": 400.0,
    "height": 40.0,
    "age": 3,
    "isFemale": false,
    "owner": null
    }
    ]''';

    tPetList = [
      Pet(
        id: "1",
        name: "Kira",
        species: Species.dog,
        age: 10,
        weight: 250.0,
        height: 20.0,
        isFemale: true,
        owner: null,
      ),
      Pet(
        id: "2",
        name: "Harribart",
        species: Species.bird,
        age: 3,
        weight: 400.0,
        height: 40.0,
        isFemale: false,
        owner: null,
      ),
    ];

    tPet = Pet(
      id: "3",
      name: "Fifi",
      species: Species.cat,
      age: 2,
      weight: 300.0,
      height: 25.0,
      isFemale: true,
      owner: null,
    );

    tPetJson = '''{
        "id": "3",
        "name": "Fifi",
        "species": 1,
        "weight": 15.0,
        "height": 10.0,
        "age": 2,
        "isFemale": false,
        "owner": null
      }''';
  });

  test("Should return a List<Pet> successfully", () async {
    when(
      () => mockHttpClient.get(Uri.parse("$baseUrl/pets")),
    ).thenAnswer((_) async => http.Response(tPetsJson, 200));

    final result = await restPetRepository.getAllPets();

    expect(listEquals(result, tPetList), true);

    verify(() => mockHttpClient.get(Uri.parse("$baseUrl/pets"))).called(1);

    verifyNever(() => mockHttpClient.get(Uri.parse("$baseUrl/pets/1")));
  });

  group("getAllPets", () {
    test("should return a List<Pet> succesfully", () async {
      when(
        () => mockHttpClient.get(Uri.parse("$baseUrl/pets")),
      ).thenAnswer((_) async => http.Response(tPetsJson, 200));
      final result = await restPetRepository.getAllPets();
      expect(listEquals(result, tPetList), true);
    });

    test("should return an error if the request fails", () async {
      when(
        () => mockHttpClient.get(Uri.parse("$baseUrl/pets")),
      ).thenAnswer((_) async => http.Response("Something went wrong", 404));

      expectLater(
        () async => await restPetRepository.getAllPets(),
        throwsException,
      );
    });
  });

  group('addPet', () {
    test("should return a Pet when the request is successful", () async {
      when(
        () => mockHttpClient.post(
          Uri.parse("$baseUrl/pets"),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer((_) async => http.Response(tPetsJson, 201));

      await restPetRepository.addPet(tPet);

      verify(
        () => mockHttpClient.post(
          Uri.parse("$baseUrl/pets"),
          headers: any(named: "headers"),
          body: jsonEncode(tPet.toMap()),
        ),
      ).called(1);
    });
    test("should throw an exception when the request fails", () async {
      when(
        () => mockHttpClient.post(
          Uri.parse("$baseUrl/pets"),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer((_) async => http.Response("Error", 400));

      expectLater(
        () async => await restPetRepository.addPet(tPet),
        throwsException,
      );
    });
  });
  group('updatePet', () {
    test("should return void when the request is successful", () async {
      final petToUpdate = tPet.copyWith(name: "Updatet Cat");

      when(
        () => mockHttpClient.put(
          Uri.parse("$baseUrl/pets/${petToUpdate.id}"),
          headers: any(named: "headers"),
          body: any(named: "body"),
        ),
      ).thenAnswer(
        (_) async => http.Response('{"id": "${petToUpdate.id}"}', 200),
      );
    });
  });
  group('getPetById', () {
    test("should return a Pet when the request is successfull", () async {
      when(
        () => mockHttpClient.get(Uri.parse("$baseUrl/pets/${tPet.id}")),
      ).thenAnswer((_) async => http.Response(tPetJson, 200));
      final result = restPetRepository.watchPet(tPet.id);
      expect(result, tPet);
    });

    test("should throw an ecxeption when the request fails", () async {
      when(
        () => mockHttpClient.get(Uri.parse("$baseUrl/pets/${tPet.id}")),
      ).thenAnswer((_) async => http.Response("Not found", 404));
      expectLater(
        () async => restPetRepository.watchPet(tPet.id),
        throwsException,
      );
    });
  });
  group('deletePetById', () {
    test("should return void when the request is successful", () async {
      when(
        () => mockHttpClient.delete(Uri.parse("$baseUrl/pets/${tPet.id}")),
      ).thenAnswer((_) async => http.Response("", 204));

      await restPetRepository.deletePetById(tPet.id);

      verify(
        () => mockHttpClient.delete(Uri.parse("$baseUrl/pets/${tPet.id}")),
      ).called(1);
    });

    test("should throw an exception when the request fails", () async {
      when(
        () => mockHttpClient.delete(Uri.parse("$baseUrl/pets/${tPet.id}")),
      ).thenAnswer((_) async => http.Response("Error", 400));

      expectLater(
        () async => await restPetRepository.deletePetById(tPet.id),
        throwsException,
      );
    });
  });
}
