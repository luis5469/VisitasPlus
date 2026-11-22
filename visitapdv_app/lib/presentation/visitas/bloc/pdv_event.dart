part of 'pdv_bloc.dart';

abstract class PdvEvent extends Equatable {
  const PdvEvent();
  @override
  List<Object?> get props => [];
}

class PdvLoadRequested extends PdvEvent {
  const PdvLoadRequested();
}

class PdvSearchChanged extends PdvEvent {
  final String query;
  const PdvSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
