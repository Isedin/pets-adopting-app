part of 'manage_pets_cubit.dart';

sealed class ManagePetsState extends Equatable {
  const ManagePetsState();

  @override
  List<Object> get props => [];
}

class ManagePetsInitial extends ManagePetsState {}

class ManagePetsLoading extends ManagePetsState {}

class ManagePetsSuccess extends ManagePetsState {
  final List<Pet> pets;

  const ManagePetsSuccess({required this.pets});

  @override
  List<Object> get props => [pets];
}

class ManagePetsError extends ManagePetsState {}
