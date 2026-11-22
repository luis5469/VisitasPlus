import 'package:equatable/equatable.dart';
import '../../../domain/entities/novedad_entity.dart';
import '../../../core/services/camera_service.dart';

abstract class NovedadState extends Equatable {
  const NovedadState();
  @override
  List<Object?> get props => [];
}

class NovedadInitial extends NovedadState {
  const NovedadInitial();
}

class NovedadLoading extends NovedadState {
  const NovedadLoading();
}

class NovedadSubiendoImagen extends NovedadState {
  const NovedadSubiendoImagen();
}

class NovedadLoaded extends NovedadState {
  final List<NovedadEntity> novedades;
  const NovedadLoaded({required this.novedades});
  @override
  List<Object?> get props => [novedades];
}

class NovedadDetailLoaded extends NovedadState {
  final NovedadEntity novedad;
  const NovedadDetailLoaded({required this.novedad});
  @override
  List<Object?> get props => [novedad];
}

class NovedadActionSuccess extends NovedadState {
  final String message;
  final NovedadEntity? novedad;
  const NovedadActionSuccess({required this.message, this.novedad});
  @override
  List<Object?> get props => [message, novedad];
}

class NovedadImagenCapturada extends NovedadState {
  final CameraCaptura captura;
  const NovedadImagenCapturada({required this.captura});
  @override
  List<Object?> get props => [captura.rutaLocal];
}

class NovedadImagenesSincronizadas extends NovedadState {
  final int pendientes;
  const NovedadImagenesSincronizadas({required this.pendientes});
  @override
  List<Object?> get props => [pendientes];
}

class NovedadError extends NovedadState {
  final String message;
  const NovedadError(this.message);
  @override
  List<Object?> get props => [message];
}
