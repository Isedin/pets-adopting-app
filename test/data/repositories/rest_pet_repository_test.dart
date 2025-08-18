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
  late List<Pet> tPetList;

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
  group('addPet', () {});
  group('updatePet', () {});
  group('deletePetById', () {});
  group('getPetById', () {});
}
