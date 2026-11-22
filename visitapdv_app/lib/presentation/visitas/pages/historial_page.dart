import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/visita_bloc.dart';
import '../bloc/connectivity_cubit.dart';
import '../../../domain/entities/visita_entity.dart';
import '../widgets/offline_banner.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitaBloc>().add(const VisitaLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Visitas'),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
        actions: [
          BlocBuilder<ConnectivityCubit, bool>(
            builder: (_, online) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                online ? Icons.cloud_done : Icons.cloud_off,
                color: online ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: BlocBuilder<VisitaBloc, VisitaState>(
              builder: (context, state) {
                if (state is VisitaLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is VisitaError) {
                  return Center(child: Text(state.message));
                }
                if (state is VisitaLoaded) {
                  if (state.visitas.isEmpty) {
                    return const Center(child: Text('Sin visitas registradas.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<VisitaBloc>().add(const VisitaLoadRequested()),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.visitas.length,
                      itemBuilder: (_, i) {
                        final v = state.visitas[i];
                        return _VisitaCard(v);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.store),
        label: const Text('Ver PDVs'),
        onPressed: () => context.go('/pdv'),
      ),
    );
  }
}

class _VisitaCard extends StatelessWidget {
  final VisitaEntity v;
  const _VisitaCard(this.v);

  @override
  Widget build(BuildContext context) {
    final dur = v.timestampFin != null
        ? v.timestampFin!.difference(v.timestampInicio)
        : DateTime.now().difference(v.timestampInicio);
    final hhmm = '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

    final (color, icon) = switch (v.estado) {
      'EnCurso'    => (Colors.blue, Icons.play_circle),
      'Completada' => (Colors.green, Icons.check_circle),
      _            => (Colors.grey, Icons.cancel),
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: color, size: 36),
        title: Text(v.pdvNombre),
        subtitle: Text(
          '${v.timestampInicio.toLocal().toString().substring(0, 16)}  •  $hhmm',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Chip(
              label: Text(v.estado, style: const TextStyle(fontSize: 11)),
              backgroundColor: color.withOpacity(0.15),
            ),
            if (!v.sincronizado)
              const Icon(Icons.sync_problem, color: Colors.orange, size: 16),
          ],
        ),
      ),
    );
  }
}
