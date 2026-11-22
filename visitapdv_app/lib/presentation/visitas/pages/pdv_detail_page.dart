import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pdv_bloc.dart';
import '../bloc/visita_bloc.dart';
import '../../../domain/entities/pdv_entity.dart';
import '../../../domain/entities/visita_entity.dart';

class PdvDetailPage extends StatefulWidget {
  final String pdvId;
  const PdvDetailPage({super.key, required this.pdvId});

  @override
  State<PdvDetailPage> createState() => _PdvDetailPageState();
}

class _PdvDetailPageState extends State<PdvDetailPage> {
  PdvEntity? _pdv;

  @override
  void initState() {
    super.initState();
    _loadPdv();
  }

  Future<void> _loadPdv() async {
    final repo = context.read<PdvBloc>();
    // Intenta obtener desde el estado cargado
    final st = repo.state;
    if (st is PdvLoaded) {
      setState(() {
        _pdv = st.all.firstWhere((p) => p.id == widget.pdvId);
      });
    } else {
      repo.add(const PdvLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PdvBloc, PdvState>(
      listener: (context, state) {
        if (state is PdvLoaded) {
          setState(() {
            _pdv = state.all.where((p) => p.id == widget.pdvId).firstOrNull;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_pdv?.nombre ?? 'Detalle PDV')),
        body: _pdv == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final pdv = _pdv!;
    return BlocBuilder<VisitaBloc, VisitaState>(
      builder: (context, visitaSt) {
        final activa = visitaSt is VisitaLoaded ? visitaSt.visitaActiva : null;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow('Código',      pdv.codigo),
              _InfoRow('Dirección',   pdv.direccion),
              _InfoRow('Ciudad',      pdv.ciudad),
              if (pdv.zona != null)        _InfoRow('Zona',         pdv.zona!),
              if (pdv.responsable != null) _InfoRow('Responsable',  pdv.responsable!),
              if (pdv.telefono != null)    _InfoRow('Teléfono',     pdv.telefono!),
              _InfoRow('Geofence',    '${pdv.geofenceMetros} m'),
              _InfoRow('Coordenadas', '${pdv.latitud}, ${pdv.longitud}'),
              const SizedBox(height: 24),
              if (activa != null && activa.pdvId != pdv.id)
                const _Aviso('Ya tienes una visita activa en otro PDV.'),
              if (activa != null && activa.pdvId == pdv.id)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_alert_rounded),
                        label: const Text('Registrar Novedad'),
                        onPressed: () => context.push('/novedades/crear?visitaId=${activa.id}&pdvId=${pdv.id}'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BtnFinalizar(activa),
                  ],
                )
              else if (activa == null)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar Visita'),
                    onPressed: () =>
                        context.push('/visitas/iniciar/${pdv.id}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 110,
              child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Text(value)),
          ],
        ),
      );
}

class _Aviso extends StatelessWidget {
  final String msg;
  const _Aviso(this.msg);
  @override
  Widget build(BuildContext context) => Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ]),
        ),
      );
}

class _BtnFinalizar extends StatelessWidget {
  final VisitaEntity visita;
  const _BtnFinalizar(this.visita);
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.stop),
          label: const Text('Finalizar Visita'),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => context.push('/visitas/finalizar/${visita.id}'),
        ),
      );
}
