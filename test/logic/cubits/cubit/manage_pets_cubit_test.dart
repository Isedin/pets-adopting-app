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
  late MockFireStorePetRepository mockFireStorePetRepository;
  late List<Pet> tPetList;

  setUp(() {
    mockFireStorePetRepository = MockFireStorePetRepository();

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
        imageUrl: null,
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
        imageUrl: null,
      ),
    ];
  });

  group('ManagePetsCubit - Stream-based fetching', () {
    blocTest<ManagePetsCubit, ManagePetsState>(
      'emits [success] when repository stream emits pets',
      build: () {
        when(
          () => mockFireStorePetRepository.getAllPetsAsStream(),
        ).thenAnswer((_) => Stream.value(tPetList));
        return ManagePetsCubit(mockFireStorePetRepository);
      },
      expect: () => [
        ManagePetsState(status: ManagePetsStatus.success, pets: tPetList),
      ],
      verify: (_) {
        verify(() => mockFireStorePetRepository.getAllPetsAsStream()).called(1);
      },
    );

    blocTest<ManagePetsCubit, ManagePetsState>(
      'emits [error] when repository stream throws',
      build: () {
        when(
          () => mockFireStorePetRepository.getAllPetsAsStream(),
        ).thenAnswer((_) => Stream.error(Exception('firestore fail')));
        return ManagePetsCubit(mockFireStorePetRepository);
      },
      expect: () => [
        isA<ManagePetsState>()
            .having((s) => s.status, 'status', ManagePetsStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', contains('fail')),
      ],
    );
  });
}
