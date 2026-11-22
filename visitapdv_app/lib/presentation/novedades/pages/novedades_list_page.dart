import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/novedad_bloc.dart';
import '../../visitas/bloc/visita_bloc.dart';
import '../widgets/estado_badge.dart';
import '../widgets/filtro_bar.dart';

class NovedadesListPage extends StatefulWidget {
  final String? visitaId;
  const NovedadesListPage({super.key, this.visitaId});

  @override
  State<NovedadesListPage> createState() => _NovedadesListPageState();
}

class _NovedadesListPageState extends State<NovedadesListPage> {
  String? _estadoFiltro;
  String? _categoriaFiltro;

  @override
  void initState() {
    super.initState();
    // Por defecto, mostrar solo las novedades con estado Abierta (pendientes)
    _estadoFiltro = 'Abierta';
    _cargar();
  }

  void _cargar() {
    if (widget.visitaId != null) {
      context.read<NovedadBloc>().add(
            NovedadByVisitaRequested(widget.visitaId!));
    } else {
      context.read<NovedadBloc>().add(NovedadLoadRequested(
            estado: _estadoFiltro,
            categoria: _categoriaFiltro,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novedades'),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        onPressed: () {
          final visitaState = context.read<VisitaBloc>().state;
          final activa = visitaState is VisitaLoaded ? visitaState.visitaActiva : null;

          if (activa != null) {
            context.push('/novedades/crear?visitaId=${activa.id}&pdvId=${activa.pdvId}');
          } else {
            showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Sin Visita Activa'),
                  ],
                ),
                content: const Text(
                  'Para registrar una novedad debes iniciar una visita en un Punto de Venta. ¿Deseas ir al listado de locales?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/pdv');
                    },
                    child: const Text('Ir a locales'),
                  ),
                ],
              ),
            );
          }
        },
      ),
      body: Column(
        children: [
          if (_estadoFiltro != null || _categoriaFiltro != null)
            FiltroBar(
              estado: _estadoFiltro,
              categoria: _categoriaFiltro,
              onClear: () {
                setState(() {
                  _estadoFiltro = null;
                  _categoriaFiltro = null;
                });
                _cargar();
              },
            ),
          Expanded(
            child: BlocBuilder<NovedadBloc, NovedadState>(
              builder: (context, state) {
                if (state is NovedadLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is NovedadError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        TextButton(
                            onPressed: _cargar,
                            child: const Text('Reintentar')),
                      ],
                    ),
                  );
                }
                if (state is NovedadLoaded) {
                  final novedades = state.novedades;
                  if (novedades.isEmpty) {
                    return const Center(
                        child: Text('No hay novedades registradas.'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async => _cargar(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: novedades.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final n = novedades[i];
                        return Card(
                          child: ListTile(
                            leading: EstadoBadge(estado: n.estado),
                            title: Text(n.titulo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                              '${n.categoria}  •  ${n.prioridad}\n'
                              '${DateFormat('dd/MM/yyyy').format(n.fechaSeguimiento)}',
                            ),
                            trailing: n.imagenes.isNotEmpty
                                ? Badge(
                                    label: Text('${n.imagenes.length}'),
                                    child: const Icon(Icons.image),
                                  )
                                : null,
                            isThreeLine: true,
                            onTap: () =>
                                context.push('/novedades/${n.id}'),
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

  void _mostrarFiltros() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => _FiltroSheet(
        estadoActual: _estadoFiltro,
        categoriaActual: _categoriaFiltro,
        onAplicar: (estado, categoria) {
          setState(() {
            _estadoFiltro = estado;
            _categoriaFiltro = categoria;
          });
          _cargar();
        },
      ),
    );
  }
}

// ─── Filtro Bottom Sheet ─────────────────────────────────────────────────────
class _FiltroSheet extends StatefulWidget {
  final String? estadoActual;
  final String? categoriaActual;
  final void Function(String?, String?) onAplicar;

  const _FiltroSheet({
    this.estadoActual,
    this.categoriaActual,
    required this.onAplicar,
  });

  @override
  State<_FiltroSheet> createState() => _FiltroSheetState();
}

class _FiltroSheetState extends State<_FiltroSheet> {
  static const _estados = [
    'Abierta', 'EnProgreso', 'Resuelta', 'Cerrada', 'Reabierta', 'Vencida'
  ];
  static const _categorias = [
    'Inventario', 'Limpieza', 'Exhibición', 'Precio', 'Equipamiento', 'Otro'
  ];

  String? _estado;
  String? _categoria;

  @override
  void initState() {
    super.initState();
    _estado = widget.estadoActual;
    _categoria = widget.categoriaActual;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _estados
                .map((e) => ChoiceChip(
                      label: Text(e),
                      selected: _estado == e,
                      onSelected: (v) =>
                          setState(() => _estado = v ? e : null),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Categoría',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _categorias
                .map((c) => ChoiceChip(
                      label: Text(c),
                      selected: _categoria == c,
                      onSelected: (v) =>
                          setState(() => _categoria = v ? c : null),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onAplicar(null, null);
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onAplicar(_estado, _categoria);
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
