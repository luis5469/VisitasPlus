part of 'pdv_bloc.dart';

abstract class PdvState extends Equatable {
  const PdvState();
  @override
  List<Object?> get props => [];
}

class PdvInitial extends PdvState {
  const PdvInitial();
}

class PdvLoading extends PdvState {
  const PdvLoading();
}

class PdvLoaded extends PdvState {
  final List<PdvEntity> all;
  final List<PdvEntity> filtered;

  const PdvLoaded({required this.all, required this.filtered});

  @override
  List<Object?> get props => [all, filtered];
}

class PdvError extends PdvState {
  final String message;
  const PdvError(this.message);
  @override
  List<Object?> get props => [message];
}
