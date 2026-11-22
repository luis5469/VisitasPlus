import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pdv_bloc.dart';
import '../bloc/visita_bloc.dart';
import '../../../core/services/gps_service.dart';
import '../../../domain/entities/pdv_entity.dart';
import '../../../core/di/injection.dart';
import '../../../core/constants/api_constants.dart';

class IniciarVisitaPage extends StatefulWidget {
  final String pdvId;
  const IniciarVisitaPage({super.key, required this.pdvId});

  @override
  State<IniciarVisitaPage> createState() => _IniciarVisitaPageState();
}

class _IniciarVisitaPageState extends State<IniciarVisitaPage> {
  Position? _pos;
  PdvEntity? _pdv;
  String? _gpsError;
  bool _loading = true;
  final _gpsService = getIt<GpsService>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Obtener PDV
    final pdvState = context.read<PdvBloc>().state;
    if (pdvState is PdvLoaded) {
      _pdv = pdvState.all.where((p) => p.id == widget.pdvId).firstOrNull;
    }

    // Obtener GPS
    try {
      _pos = await _gpsService.getCurrentPosition().timeout(const Duration(seconds: 6));
      if (_pos == null) {
        setState(() => _gpsError = 'No se pudo obtener la ubicación GPS.');
      }
    } catch (e) {
      setState(() => _gpsError = 'Error GPS: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Visita')),
      body: BlocListener<VisitaBloc, VisitaState>(
        listener: (context, state) {
          if (state is VisitaActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.go('/pdv');
          } else if (state is VisitaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_pdv == null) {
      return const Center(child: Text('PDV no encontrado.'));
    }
    final pdv = _pdv!;
    double? dist;
    bool dentro = false;

    if (_pos != null) {
      dist = _gpsService.distanciaMetros(
          _pos!.latitude, _pos!.longitude, pdv.latitud, pdv.longitud);
      dentro = _gpsService.estaDentroDeGeofence(
          _pos!.latitude, _pos!.longitude, pdv.latitud, pdv.longitud, pdv.geofenceMetros);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(pdv.nombre, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(pdv.direccion, style: Theme.of(context).textTheme.bodyMedium),
          const Divider(height: 32),

          if (_gpsError != null) ...[
            _Alerta(Colors.red, Icons.gps_off, _gpsError!),
            const SizedBox(height: 8),
            if (ApiConstants.isTestingMode) ...[
              const _Alerta(Colors.blue, Icons.info_outline, 'Modo Pruebas Activo: Se permite iniciar la visita usando coordenadas por defecto.'),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar obtener ubicación'),
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _gpsError = null;
                    _pos = null;
                  });
                  _init();
                },
              ),
            ),
          ] else if (_pos != null) ...[
            _GpsFila('Tu posición', '${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}'),
            _GpsFila('Distancia al PDV', '${dist!.toStringAsFixed(0)} m (geofence: ${pdv.geofenceMetros} m)'),
            const SizedBox(height: 12),
            if (dentro)
              _Alerta(Colors.green, Icons.check_circle, 'Estás dentro del área del PDV.')
            else if (ApiConstants.isTestingMode)
              _Alerta(Colors.blue, Icons.info_outline, 'Fuera del área del PDV (${dist.toStringAsFixed(0)} m) [Pruebas Activas - Permitido]')
            else
              _Alerta(Colors.orange, Icons.warning, 'Estás fuera del área del PDV (${dist.toStringAsFixed(0)} m).'),
          ],

          const SizedBox(height: 32),

          BlocBuilder<VisitaBloc, VisitaState>(
            builder: (context, state) {
              final busy = state is VisitaLoading;
              final canStart = !busy && (_pos != null || ApiConstants.isTestingMode);
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar inicio de visita'),
                  onPressed: !canStart
                      ? null
                      : () {
                          final lat = _pos?.latitude ?? pdv.latitud;
                          final lng = _pos?.longitude ?? pdv.longitud;
                          context.read<VisitaBloc>().add(
                                VisitaIniciarRequested(
                                  pdvId: pdv.id,
                                  latitud: lat,
                                  longitud: lng,
                                ),
                              );
                        },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GpsFila extends StatelessWidget {
  final String label, value;
  const _GpsFila(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 140, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );
}

class _Alerta extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String msg;
  const _Alerta(this.color, this.icon, this.msg);
  @override
  Widget build(BuildContext context) => Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ]),
        ),
      );
}
