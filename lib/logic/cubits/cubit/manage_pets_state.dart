part of 'manage_pets_cubit.dart';

enum ManagePetsStatus { initial, loading, success, error }

class ManagePetsState extends Equatable {
  /// Der [status] gibt an, in welchem Zustand sich der [ManagePetsState] befindet
  final ManagePetsStatus status;

  /// Die [pets] sind die Kuscheltiere, die aus Firestore geladen wurden
  final List<Pet> pets;

  /// Die [errorMessage] ist die Fehlermeldung, die angezeigt wird, wenn ein Fehler auftritt
  final String? errorMessage;

  const ManagePetsState({
    this.status = ManagePetsStatus.initial,
    this.pets = const [],
    this.errorMessage,
  });

  ManagePetsState copyWith({
    ManagePetsStatus? status,
    List<Pet>? pets,
    String? errorMessage,
  }) {
    return ManagePetsState(
      status: status ?? this.status,
      pets: pets ?? this.pets,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [status, pets, errorMessage ?? ''];
}
