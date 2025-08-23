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
    cubit = ManagePetsCubit(mockFireStorePetRepository);

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
  });
  group('getAllPets', () {
    blocTest<ManagePetsCubit, ManagePetsState>(
      'emits [ManagePetsStatus.loading, ManagePetsStatus.success] when getAllPets() is called successfully.',
      setUp: () {
        when(
          () => mockFireStorePetRepository.getAllPets(),
        ).thenAnswer((_) async => tPetList);
      },
      build: () => cubit,
      act: (cubit) => cubit.getAllPets(),
      expect: () => <ManagePetsState>[
        const ManagePetsState(status: ManagePetsStatus.loading),
        ManagePetsState(status: ManagePetsStatus.success, pets: tPetList),
      ],
      verify: (_) {
        verify(() => mockFireStorePetRepository.getAllPets()).called(1);
      },
    );
  });
}
