import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/dashboard_model.dart';

class HeatmapPdvMap extends StatelessWidget {
  final List<HeatmapPuntoModel> puntos;

  const HeatmapPdvMap({super.key, required this.puntos});

  @override
  Widget build(BuildContext context) {
    if (puntos.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Sin datos geográficos')),
        ),
      );
    }

    final center = LatLng(
      puntos.map((p) => p.latitud).reduce((a, b) => a + b) / puntos.length,
      puntos.map((p) => p.longitud).reduce((a, b) => a + b) / puntos.length,
    );

    final maxVisitas =
        puntos.map((p) => p.cantidadVisitas).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Mapa de Calor — Puntos de Venta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.farmaenlace.visitapdv',
                ),
                MarkerLayer(
                  markers: puntos.map((p) {
                    final ratio = maxVisitas > 0
                        ? p.cantidadVisitas / maxVisitas
                        : 0.0;
                    final color = Color.lerp(
                      Colors.blue.shade200,
                      Colors.red.shade700,
                      ratio,
                    )!;
                    final size = 20.0 + ratio * 24;

                    return Marker(
                      point: LatLng(p.latitud, p.longitud),
                      width: size,
                      height: size,
                      child: GestureDetector(
                        onTap: () => _showPopup(context, p),
                        child: Tooltip(
                          message:
                              '${p.nombrePdv}\n${p.cantidadVisitas} visitas\n'
                              '${p.novedadesAbiertas} novedades abiertas',
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                    color: color.withOpacity(0.4),
                                    blurRadius: 6,
                                    spreadRadius: 2),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                p.cantidadVisitas.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _GradientLegend(),
                const SizedBox(width: 8),
                Text('Menor', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                const Spacer(),
                Text('Mayor actividad', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPopup(BuildContext context, HeatmapPuntoModel p) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.nombrePdv,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _InfoRow(Icons.pin_drop, 'Visitas', p.cantidadVisitas.toString()),
            _InfoRow(Icons.report_problem_outlined, 'Novedades abiertas',
                p.novedadesAbiertas.toString()),
            _InfoRow(Icons.location_on_outlined, 'Coordenadas',
                '${p.latitud.toStringAsFixed(6)}, ${p.longitud.toStringAsFixed(6)}'),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class _GradientLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.red.shade700],
        ),
      ),
    );
  }
}
