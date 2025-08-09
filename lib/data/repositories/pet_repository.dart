import 'package:pummel_the_fish/data/models/pet.dart';

abstract class PetRepository {
  Pet? getPetById(String id);
  List<Pet> getAllPets();
  void addPet(Pet pet);
  void deletePetById(String id);
}
