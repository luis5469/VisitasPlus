import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../bloc/visita_bloc.dart';
import '../../../core/services/gps_service.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/visita_entity.dart';

class FinalizarVisitaPage extends StatefulWidget {
  final String visitaId;
  const FinalizarVisitaPage({super.key, required this.visitaId});

  @override
  State<FinalizarVisitaPage> createState() => _FinalizarVisitaPageState();
}

class _FinalizarVisitaPageState extends State<FinalizarVisitaPage> {
  Position? _pos;
  VisitaEntity? _visita;
  bool _loading = true;
  String? _gpsError;
  final _gpsService = getIt<GpsService>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Buscar visita activa en BLoC
    final st = context.read<VisitaBloc>().state;
    if (st is VisitaLoaded) {
      _visita = st.visitaActiva?.id == widget.visitaId
          ? st.visitaActiva
          : st.visitas.where((v) => v.id == widget.visitaId).firstOrNull;
    }
    // GPS
    try {
      _pos = await _gpsService.getCurrentPosition();
    } catch (_) {
      _gpsError = 'No se pudo obtener GPS';
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Visita')),
      body: BlocListener<VisitaBloc, VisitaState>(
        listener: (context, state) {
          if (state is VisitaActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            context.go('/historial');
          } else if (state is VisitaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_visita == null) {
      return const Center(child: Text('Visita no encontrada.'));
    }
    final v    = _visita!;
    final dur  = DateTime.now().difference(v.timestampInicio);
    final hhmm = '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(v.pdvNombre, style: Theme.of(context).textTheme.headlineSmall),
          const Divider(height: 32),
          _Fila('Inicio',    v.timestampInicio.toLocal().toString().substring(0, 16)),
          _Fila('Duración',  hhmm),
          _Fila('Estado',    v.estado),
          const SizedBox(height: 16),
          if (_gpsError != null)
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_gpsError!)),
                ]),
              ),
            ),
          if (_pos != null)
            _Fila('Tu GPS', '${_pos!.latitude.toStringAsFixed(5)}, ${_pos!.longitude.toStringAsFixed(5)}'),
          const SizedBox(height: 32),
          BlocBuilder<VisitaBloc, VisitaState>(
            builder: (context, state) {
              final busy = state is VisitaLoading;
              return SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.stop),
                  label: busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Confirmar finalización'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: busy
                      ? null
                      : () => context.read<VisitaBloc>().add(
                            VisitaFinalizarRequested(
                              visitaId: v.id,
                              latitud:  _pos?.latitude  ?? 0,
                              longitud: _pos?.longitude ?? 0,
                            ),
                          ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String label, value;
  const _Fila(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          SizedBox(width: 110, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ]),
      );
}
