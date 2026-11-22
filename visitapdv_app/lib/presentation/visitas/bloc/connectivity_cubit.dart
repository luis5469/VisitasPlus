import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:visitapdv_app/core/services/connectivity_service.dart';

@injectable
class ConnectivityCubit extends Cubit<bool> {
  final ConnectivityService _service;

  ConnectivityCubit(this._service) : super(true) {
    emit(_service.isOnline);
    _service.onConnectivityChanged.listen(emit);
  }
}
