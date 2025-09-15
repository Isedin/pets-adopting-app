part of 'species_cubit.dart';

class SpeciesState extends Equatable {
  final bool isLoading;
  final List<AppSpecies> items;
  final String? error;

  const SpeciesState._(this.isLoading, this.items, this.error);
  const SpeciesState.loading() : this._(true, const [], null);
  const SpeciesState.loaded(List<AppSpecies> items) : this._(false, items, null);
  const SpeciesState.error(String e) : this._(false, const [], e);

  @override
  List<Object?> get props => [isLoading, items, error];
}
