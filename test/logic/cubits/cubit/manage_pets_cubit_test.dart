import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pummel_the_fish/data/models/pet.dart';
import 'package:pummel_the_fish/data/repositories/firestore_pet_repository.dart';
import 'package:pummel_the_fish/logic/cubits/cubit/manage_pets_cubit.dart';
import 'package:pummel_the_fish/widgets/enums/species_enum.dart';

class MockFireStorePetRepository extends Mock
    implements FirestorePetRepository {}

void main() {
  late ManagePetsCubit cubit;
  late MockFireStorePetRepository mockFireStorePetRepository;

  late List<Pet> tPetList;

  setUp(() {
    mockFireStorePetRepository = MockFireStorePetRepository();

    /// initialize test pets list

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
        name: "Space",
        species: Species.fish,
        age: 3,
        weight: 400.0,
        height: 40.0,
        isFemale: false,
        owner: null,
      ),
    ];

    /// when getAllPetsAsStream() is called on mockFireStorePetRepository, we return a stream of the test pets list
    when(
      () => mockFireStorePetRepository.getAllPetsAsStream(),
    ).thenAnswer((_) => Stream.value(tPetList));

    /// initialize cubit, that automatically runs the stream in constructor
    cubit = ManagePetsCubit(mockFireStorePetRepository);
  });
  group('Stream-based pet fetching', () {
    blocTest<ManagePetsCubit, ManagePetsState>(
      'emits [ManagePetsStatus.loading, ManagePetsStatus.success] when getAllPets() is called successfully.',

      build: () => cubit,
      act: (cubit) async {},
      expect: () => [
        ManagePetsState(status: ManagePetsStatus.success, pets: tPetList),
      ],
      verify: (_) {
        /// we verify that the method getAllPetsAsStream() was indeed called.
        verify(() => mockFireStorePetRepository.getAllPetsAsStream()).called(1);
      },
    );
  });
}
