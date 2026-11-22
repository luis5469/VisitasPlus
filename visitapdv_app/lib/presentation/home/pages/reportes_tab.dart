import 'package:flutter/material.dart';

class ReportesTab extends StatelessWidget {
  const ReportesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Gestión'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Card 1: Cumplimiento
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cumplimiento',
                          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Visitas realizadas contra la planificación del mes en curso.',
                          style: tt.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00695C),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('35 Ejecutadas', style: tt.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 16),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: Color(0xFFCBD5E1),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text('3 Pendientes', style: tt.bodySmall?.copyWith(color: const Color(0xFF64748B))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: CircularProgressIndicator(
                          value: 0.92,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          color: cs.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const Text(
                        '92%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Card 2: Novedades por Categoría
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novedades por Categoría',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distribución de incidencias reportadas en puntos de venta.',
                    style: tt.bodySmall?.copyWith(color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  _buildCategoryBar('Quiebre de Stock (Stock Out)', 0.65, const Color(0xFF8D4A36), '12 casos'),
                  _buildCategoryBar('Precios Incorrectos', 0.40, const Color(0xFF26A69A), '6 casos'),
                  _buildCategoryBar('Publicidad Dañada', 0.20, const Color(0xFF747876), '3 casos'),
                  _buildCategoryBar('Otros', 0.10, const Color(0xFFCBD5E1), '1 caso'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String title, double percentage, Color color, String count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: justifySpread,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: const Color(0xFFF1F5F9),
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const MainAxisAlignment justifySpread = MainAxisAlignment.spaceBetween;
}
