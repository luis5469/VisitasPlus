import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/imagen_offline_queue.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../../novedades/bloc/novedad_bloc.dart';
import '../../visitas/bloc/visita_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Cargar datos del visitador al inicio
    _refreshData();

    // Escuchar cambios de conectividad para refrescar UI del estado de sync
    _connectivitySubscription = getIt<ConnectivityService>()
        .onConnectivityChanged
        .listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _refreshData() {
    context.read<VisitaBloc>().add(const VisitaLoadRequested());
    context.read<NovedadBloc>().add(const NovedadLoadRequested());
    context.read<NovedadBloc>().add(const NovedadSincronizarImagenesRequested());
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return "$hour:$minute $suffix";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    // Calcular estado de sincronización
    final isOnline = getIt<ConnectivityService>().isOnline;
    final pendingQueue = getIt<ImagenOfflineQueue>().pendientes;
    final bool hasPendingSync = pendingQueue > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: BlocBuilder<VisitaBloc, VisitaState>(
          builder: (context, visitaState) {
            return BlocBuilder<NovedadBloc, NovedadState>(
              builder: (context, novedadState) {
                final visitas = visitaState is VisitaLoaded ? visitaState.visitas : [];
                final activa = visitaState is VisitaLoaded ? visitaState.visitaActiva : null;
                final novedades = novedadState is NovedadLoaded ? novedadState.novedades : [];

                // Métricas
                final totalProgramados = visitas.length;
                final visitadosCount = visitas.where((v) => v.estaCompletada).length;
                final pendientesCount = visitas.where((v) => !v.estaCompletada && !v.estaEnCurso).length;
                final novedadesCount = novedades.length;

                // Acciones críticas
                final novedadesCriticasCount = novedades.where((n) =>
                    (n.estaAbierta || n.estaEnProgreso) &&
                    (n.prioridad.toLowerCase() == 'alta' || n.prioridad.toLowerCase() == 'critica')
                ).length;
                final novedadesAbiertasCount = novedades.where((n) => n.estaAbierta || n.estaEnProgreso).length;

                // Porcentaje cumplimiento
                final double cumplimiento = totalProgramados > 0 
                    ? (visitadosCount / totalProgramados) * 100 
                    : 0.0;

                // Actividad Reciente
                final List<_ActivityItem> recentActivities = [];
                final today = DateTime.now();

                // 1. Visitas completadas hoy
                for (final v in visitas.where((v) => v.estaCompletada)) {
                  final time = v.timestampFin ?? v.timestampInicio;
                  if (time.year == today.year && time.month == today.month && time.day == today.day) {
                    recentActivities.add(_ActivityItem(
                      title: v.pdvNombre,
                      subtitle: 'Visita completada',
                      time: _formatTime(time),
                      timestamp: time,
                      isSuccess: true,
                    ));
                  }
                }

                // 2. Novedades de hoy
                for (final n in novedades) {
                  final time = n.creadoEn;
                  if (time.year == today.year && time.month == today.month && time.day == today.day) {
                    final pdvName = visitas.where((v) => v.pdvId == n.pdvId).firstOrNull?.pdvNombre ?? 'Punto de Venta';
                    recentActivities.add(_ActivityItem(
                      title: pdvName,
                      subtitle: '${n.categoria} reportado',
                      time: _formatTime(time),
                      timestamp: time,
                      isSuccess: false,
                    ));
                  }
                }

                // Ordenar por hora descendente
                recentActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshData();
                  },
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // 1. Cabecera Perfil y Sync
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: cs.primary.withOpacity(0.1),
                            child: Text(
                              user != null && user.nombreCompleto.isNotEmpty
                                  ? user.nombreCompleto.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                  : 'U',
                              style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.nombreCompleto ?? 'Usuario',
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: !isOnline
                                            ? const Color(0xFF8D4A36) // Red/Brown if offline
                                            : hasPendingSync
                                                ? const Color(0xFFD97706) // Orange if pending sync
                                                : const Color(0xFF10B981), // Green if active & clean
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      !isOnline
                                          ? 'Sin Conexión'
                                          : hasPendingSync
                                              ? 'Pendiente de Sincronizar ($pendingQueue)'
                                              : 'Sincronización Activa',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: !isOnline
                                            ? const Color(0xFF8D4A36)
                                            : hasPendingSync
                                                ? const Color(0xFFD97706)
                                                : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _refreshData,
                            icon: const Icon(Icons.sync_rounded, color: Color(0xFF00695C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Banner de visita activa en curso
                      if (activa != null) ...[
                        Card(
                          color: const Color(0xFFE0F2F1), // Soft Primary
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFB2DFDB)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.flash_on_rounded, color: Color(0xFF00695C), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Visita en Curso Activa',
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF00695C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Visitando actualmente:',
                                  style: tt.bodySmall?.copyWith(color: const Color(0xFF004D40)),
                                ),
                                Text(
                                  '${activa.pdvNombre} (${activa.pdvCodigo})',
                                  style: tt.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF004D40),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: const Color(0xFF00695C),
                                          side: const BorderSide(color: Color(0xFF00695C)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.add_alert_rounded, size: 16),
                                        label: const Text('Novedad', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        onPressed: () => context.push('/novedades/crear?visitaId=${activa.id}&pdvId=${activa.pdvId}'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF8D4A36), // Style guide tertiary brown
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.stop_rounded, size: 16),
                                        label: const Text('Finalizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        onPressed: () => context.push('/visitas/finalizar/${activa.id}'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 3. Hoja de Ruta Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HOJA DE RUTA',
                                style: tt.labelMedium?.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              Text(
                                'Planificación de Hoy',
                                style: tt.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$totalProgramados PDVs',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. Counters Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildCounterCard(
                              count: '$visitadosCount',
                              label: 'Visitados',
                              color: const Color(0xFF10B981),
                              bgColor: const Color(0xFFECFDF5),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCounterCard(
                              count: '$pendientesCount',
                              label: 'Pendientes',
                              color: const Color(0xFF8D4A36), // Brown
                              bgColor: const Color(0xFFFDF8F6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCounterCard(
                              count: '$novedadesCount',
                              label: 'Novedades',
                              color: const Color(0xFFEF4444),
                              bgColor: const Color(0xFFFEF2F2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 5. Puntos de Venta Card
                      Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        child: InkWell(
                          onTap: () => context.push('/pdv'),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2F1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF00695C), size: 24),
                                    ),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '$totalProgramados',
                                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                        ),
                                        const Text('Asignados', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Puntos de Venta',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                ),
                                const Text(
                                  'Gestión de cartera regional',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE0F2F1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$pendientesCount PENDIENTES',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
                                      ),
                                    ),
                                    const Row(
                                      children: [
                                        Text(
                                          'VER MAPA',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00695C)),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF00695C)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. Novedades & Historial Grid Row
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              color: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: InkWell(
                                onTap: () => context.push('/novedades'),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.assignment_outlined, color: Color(0xFF8D4A36), size: 24),
                                          if (novedadesCriticasCount > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFEF2F2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                '$novedadesCriticasCount CRÍTICAS',
                                                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Novedades',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$novedadesAbiertasCount Abiertas hoy',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Card(
                              color: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              child: InkWell(
                                onTap: () => context.push('/historial'),
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Icon(Icons.history_rounded, color: Color(0xFF747876), size: 24),
                                          if (cumplimiento > 0)
                                            Row(
                                              children: [
                                                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${cumplimiento.toInt()}% Cumpl.',
                                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Historial',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$visitadosCount Visitas',
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 7. Recent Activity List Title
                      Text(
                        'ACTIVIDAD RECIENTE',
                        style: tt.labelMedium?.copyWith(
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Activity list cards
                      if (recentActivities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No hay actividad reciente registrada hoy.',
                              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      else
                        ...recentActivities.map((act) => _buildRecentActivityRow(act)),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required String count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityRow(_ActivityItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.isSuccess ? const Color(0xFFECFDF5) : const Color(0xFFFDF8F6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isSuccess ? Icons.check_circle_outline_rounded : Icons.warning_amber_rounded,
              color: item.isSuccess ? const Color(0xFF10B981) : const Color(0xFF8D4A36),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.subtitle} • ${item.time}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }
}

class _ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final DateTime timestamp;
  final bool isSuccess;

  _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.timestamp,
    required this.isSuccess,
  });
}
