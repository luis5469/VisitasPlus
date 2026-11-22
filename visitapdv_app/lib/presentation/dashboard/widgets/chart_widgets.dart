import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';

// ─── Gráfica de barras: Incidencias por Categoría ───────────────────────────
class IncidenciasCategoriaChart extends StatelessWidget {
  final List<IncidenciaCategoriaModel> datos;

  const IncidenciasCategoriaChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EmptyChart();

    final maxY = datos
        .map((d) => d.total.toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Incidencias por Categoría',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: maxY * 1.2,
                  barGroups: datos.asMap().entries.map((e) {
                    final i = e.key;
                    final d = e.value;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: d.total.toDouble(),
                          color: Colors.blue.shade600,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                          rodStackItems: [
                            BarChartRodStackItem(0, d.resueltas.toDouble(),
                                Colors.green.shade400),
                            BarChartRodStackItem(d.resueltas.toDouble(),
                                d.total.toDouble(), Colors.blue.shade300),
                          ],
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= datos.length) {
                            return const SizedBox.shrink();
                          }
                          final label = datos[idx].categoria;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              label.length > 8
                                  ? '${label.substring(0, 8)}…'
                                  : label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Legend(items: const [
              ('Resueltas', Colors.green),
              ('Abiertas', Colors.blue),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Gráfica de líneas: Timeline de Novedades ────────────────────────────────
class NovedadesTimelineChart extends StatelessWidget {
  final List<NovedadesTimelineModel> datos;

  const NovedadesTimelineChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const _EmptyChart();

    LineChartBarData _line(
        List<FlSpot> spots, Color color, bool dotted) {
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: 2.5,
        isStrokeCapRound: true,
        dotData: FlDotData(show: datos.length <= 15),
        dashArray: dotted ? [5, 4] : null,
        belowBarData: BarAreaData(
          show: !dotted,
          color: color.withOpacity(0.07),
        ),
      );
    }

    List<FlSpot> getSpots(int Function(NovedadesTimelineModel) getter) {
      return datos.asMap().entries
          .map((e) => FlSpot(e.key.toDouble(), getter(e.value).toDouble()))
          .toList();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evolución de Novedades',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    _line(getSpots((d) => d.abiertas), Colors.blue, false),
                    _line(getSpots((d) => d.enProgreso), Colors.orange, false),
                    _line(getSpots((d) => d.resueltas), Colors.green, false),
                    _line(getSpots((d) => d.cerradas), Colors.grey, true),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (datos.length / 5).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= datos.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              DateFormat('dd/MM').format(datos[idx].fecha),
                              style: const TextStyle(fontSize: 9),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Legend(items: const [
              ('Abiertas', Colors.blue),
              ('En Progreso', Colors.orange),
              ('Resueltas', Colors.green),
              ('Cerradas', Colors.grey),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Gráfica circular: Cumplimiento agenda ───────────────────────────────────
class CumplimientoAgendaChart extends StatelessWidget {
  final double porcentaje;
  final int ejecutadas;
  final int agendadas;

  const CumplimientoAgendaChart({
    super.key,
    required this.porcentaje,
    required this.ejecutadas,
    required this.agendadas,
  });

  @override
  Widget build(BuildContext context) {
    final pct = porcentaje.clamp(0.0, 100.0);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cumplimiento de Agenda',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: [
                    PieChartSectionData(
                      value: pct,
                      color: pct >= 80
                          ? Colors.green.shade500
                          : pct >= 50
                              ? Colors.orange.shade500
                              : Colors.red.shade500,
                      title: '${pct.toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      radius: 60,
                    ),
                    PieChartSectionData(
                      value: 100 - pct,
                      color: Colors.grey.shade200,
                      title: '',
                      radius: 54,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                '$ejecutadas / $agendadas visitas',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tabla: Eficiencia por Visitador ─────────────────────────────────────────
class EficienciaVisitadorTable extends StatelessWidget {
  final List<VisitadorEficienciaModel> datos;

  const EficienciaVisitadorTable({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Eficiencia por Visitador',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(Colors.blue.shade50),
                columnSpacing: 20,
                columns: const [
                  DataColumn(label: Text('Visitador')),
                  DataColumn(label: Text('Visitas'), numeric: true),
                  DataColumn(label: Text('Cumpl.%'), numeric: true),
                  DataColumn(label: Text('Novedades'), numeric: true),
                  DataColumn(label: Text('T.Prom(min)'), numeric: true),
                ],
                rows: datos
                    .map(
                      (v) => DataRow(cells: [
                        DataCell(Text(v.nombreCompleto,
                            style: const TextStyle(fontSize: 13))),
                        DataCell(Text(v.visitasCompletadas.toString())),
                        DataCell(
                          Text(
                            '${v.porcentajeCumplimiento.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: v.porcentajeCumplimiento >= 80
                                  ? Colors.green.shade700
                                  : v.porcentajeCumplimiento >= 50
                                      ? Colors.orange.shade700
                                      : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(Text(v.novedadesRegistradas.toString())),
                        DataCell(Text(
                            v.tiempoPromedioVisitaMinutos.toStringAsFixed(1))),
                      ]),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers internos ────────────────────────────────────────────────────────
class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text('Sin datos en el período',
              style: TextStyle(color: Colors.grey.shade400)),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<(String, Color)> items;

  const _Legend({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      children: items
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: item.$2,
                          borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 4),
                  Text(item.$1, style: const TextStyle(fontSize: 11)),
                ],
              ))
          .toList(),
    );
  }
}
