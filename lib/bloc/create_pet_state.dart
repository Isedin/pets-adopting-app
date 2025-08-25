part of 'create_pet_cubit.dart';

abstract class CreatePetState extends Equatable {
  const CreatePetState();

  @override
  List<Object> get props => [];
}

class CreatePetInitial extends CreatePetState {}

class CreatePetLoading extends CreatePetState {}

class CreatePetSuccess extends CreatePetState {}

class CreatePetFailure extends CreatePetState {
  final String error;

  const CreatePetFailure(this.error);

  @override
  List<Object> get props => [error];
}
