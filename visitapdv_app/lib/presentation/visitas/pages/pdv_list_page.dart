import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/pdv_bloc.dart';
import '../bloc/connectivity_cubit.dart';
import '../widgets/offline_banner.dart';

class PdvListPage extends StatefulWidget {
  const PdvListPage({super.key});

  @override
  State<PdvListPage> createState() => _PdvListPageState();
}

class _PdvListPageState extends State<PdvListPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PdvBloc>().add(const PdvLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puntos de Venta'),
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
                online ? Icons.wifi : Icons.wifi_off,
                color: online ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SearchBar(
              controller: _searchCtrl,
              hintText: 'Buscar por nombre, código o ciudad',
              leading: const Icon(Icons.search),
              onChanged: (q) =>
                  context.read<PdvBloc>().add(PdvSearchChanged(q)),
            ),
          ),
          Expanded(
            child: BlocBuilder<PdvBloc, PdvState>(
              builder: (context, state) {
                if (state is PdvLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is PdvError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<PdvBloc>().add(const PdvLoadRequested()),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is PdvLoaded) {
                  if (state.filtered.isEmpty) {
                    return const Center(child: Text('No se encontraron PDVs.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<PdvBloc>().add(const PdvLoadRequested()),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: state.filtered.length,
                      itemBuilder: (_, i) {
                        final pdv = state.filtered[i];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(pdv.codigo.substring(0, 2)),
                            ),
                            title: Text(pdv.nombre),
                            subtitle: Text('${pdv.ciudad}  •  ${pdv.direccion}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => context.push('/pdv/${pdv.id}'),
                          ),
                        );
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
    );
  }
}
