import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../data/models/dashboard_model.dart';
import '../widgets/kpi_card_widget.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/alertas_panel_widget.dart';
import '../widgets/heatmap_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _refreshInterval = Duration(minutes: 5);

  Timer? _autoRefresh;
  DateTime? _desde;
  DateTime? _hasta;

  @override
  void initState() {
    super.initState();
    _load();
    _autoRefresh = Timer.periodic(_refreshInterval, (_) {
      if (mounted) context.read<DashboardBloc>().add(const RefreshDashboard());
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  void _load() {
    context.read<DashboardBloc>().add(
          LoadDashboard(desde: _desde, hasta: _hasta),
        );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _desde ?? DateTime.now().subtract(const Duration(days: 30)),
        end: _hasta ?? DateTime.now(),
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _desde = picked.start;
        _hasta = picked.end;
      });
      _load();
    }
  }

  Future<void> _exportar(String formato) async {
    context.read<DashboardBloc>().add(
          ExportDashboard(formato: formato, desde: _desde, hasta: _hasta),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Dashboard Ejecutivo'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Seleccionar período',
            onPressed: _pickDateRange,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Exportar',
            onSelected: _exportar,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'pdf', child: Text('Exportar PDF')),
              PopupMenuItem(value: 'excel', child: Text('Exportar Excel')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () =>
                context.read<DashboardBloc>().add(const RefreshDashboard()),
          ),
        ],
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.mensaje),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is DashboardExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Exportación ${state.formato.toUpperCase()} lista (${state.bytes.length ~/ 1024} KB)'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardExporting) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Generando archivo...'),
                ],
              ),
            );
          }

          if (state is DashboardError && state is! DashboardLoaded) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(state.mensaje,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _load, child: const Text('Reintentar')),
                ],
              ),
            );
          }

          if (state is DashboardLoaded || state is DashboardExportSuccess) {
            final data = state is DashboardLoaded
                ? state.data
                : (context.read<DashboardBloc>().state is DashboardLoaded
                    ? (context.read<DashboardBloc>().state as DashboardLoaded)
                        .data
                    : null);

            if (data == null) return const SizedBox.shrink();
            return _DashboardBody(data: data, desde: _desde, hasta: _hasta);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardResumenModel data;
  final DateTime? desde;
  final DateTime? hasta;

  const _DashboardBody({required this.data, this.desde, this.hasta});

  @override
  Widget build(BuildContext context) {
    final kpis = data.kpis;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboard());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Período
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(
                'Período: ${DateFormat('dd/MM/yy').format(data.desde)} – ${DateFormat('dd/MM/yy').format(data.hasta)}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              const Spacer(),
              Text(
                'Auto-refresh cada 5 min',
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── KPI Cards ──────────────────────────────────────────────────
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              KpiCard(
                titulo: 'Novedades Abiertas',
                valor: kpis.novedadesAbiertas.toString(),
                icono: Icons.report_outlined,
                color: Colors.blue.shade600,
              ),
              KpiCard(
                titulo: 'Novedades Vencidas',
                valor: kpis.novedadesVencidas.toString(),
                icono: Icons.timer_off_outlined,
                color: Colors.red.shade600,
                esAlerta: kpis.novedadesVencidas > 0,
              ),
              KpiCard(
                titulo: 'Visitas Ejecutadas',
                valor: kpis.visitasEjecutadas.toString(),
                subtitulo: 'de ${kpis.totalAgendado} agendadas',
                icono: Icons.store_outlined,
                color: Colors.green.shade600,
              ),
              KpiCard(
                titulo: 'Cumplimiento Agenda',
                valor:
                    '${kpis.porcentajeCumplimientoAgenda.toStringAsFixed(1)}%',
                icono: Icons.check_circle_outline,
                color: kpis.porcentajeCumplimientoAgenda >= 80
                    ? Colors.green.shade600
                    : kpis.porcentajeCumplimientoAgenda >= 50
                        ? Colors.orange.shade600
                        : Colors.red.shade600,
              ),
              KpiCard(
                titulo: 'T.Resolución Promedio',
                valor: '${kpis.tiempoResolucionPromedioHoras.toStringAsFixed(1)}h',
                icono: Icons.hourglass_bottom_outlined,
                color: Colors.purple.shade600,
              ),
              KpiCard(
                titulo: 'Total Novedades',
                valor: kpis.totalNovedades.toString(),
                subtitulo: 'en el período',
                icono: Icons.list_alt_outlined,
                color: Colors.teal.shade600,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Alertas ────────────────────────────────────────────────────
          AlertasPanel(alertas: data.alertasActivas.toList()),
          const SizedBox(height: 16),

          // ── Gráfica: Incidencias por categoría ─────────────────────────
          IncidenciasCategoriaChart(
              datos: data.incidenciasPorCategoria.toList()),
          const SizedBox(height: 16),

          // ── Gráfica: Timeline ──────────────────────────────────────────
          NovedadesTimelineChart(datos: data.timeline.toList()),
          const SizedBox(height: 16),

          // ── Gráfica: Cumplimiento ──────────────────────────────────────
          CumplimientoAgendaChart(
            porcentaje: kpis.porcentajeCumplimientoAgenda,
            ejecutadas: kpis.visitasEjecutadas,
            agendadas: kpis.totalAgendado,
          ),
          const SizedBox(height: 16),

          // ── Tabla: Eficiencia por visitador ────────────────────────────
          EficienciaVisitadorTable(
              datos: data.eficienciaPorVisitador.toList()),
          const SizedBox(height: 16),

          // ── Heatmap geográfico ─────────────────────────────────────────
          HeatmapPdvMap(puntos: data.heatmap.toList()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
