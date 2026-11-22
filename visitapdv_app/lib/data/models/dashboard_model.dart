class DashboardKpiModel {
  final int novedadesAbiertas;
  final int novedadesVencidas;
  final double tiempoResolucionPromedioHoras;
  final int visitasEjecutadas;
  final double porcentajeCumplimientoAgenda;
  final int totalAgendado;
  final int totalNovedades;
  final DateTime generadoEn;

  const DashboardKpiModel({
    required this.novedadesAbiertas,
    required this.novedadesVencidas,
    required this.tiempoResolucionPromedioHoras,
    required this.visitasEjecutadas,
    required this.porcentajeCumplimientoAgenda,
    required this.totalAgendado,
    required this.totalNovedades,
    required this.generadoEn,
  });

  factory DashboardKpiModel.fromJson(Map<String, dynamic> j) =>
      DashboardKpiModel(
        novedadesAbiertas: j['novedadesAbiertas'] as int,
        novedadesVencidas: j['novedadesVencidas'] as int,
        tiempoResolucionPromedioHoras:
            (j['tiempoResolucionPromedioHoras'] as num).toDouble(),
        visitasEjecutadas: j['visitasEjecutadas'] as int,
        porcentajeCumplimientoAgenda:
            (j['porcentajeCumplimientoAgenda'] as num).toDouble(),
        totalAgendado: j['totalAgendado'] as int,
        totalNovedades: j['totalNovedades'] as int,
        generadoEn: DateTime.parse(j['generadoEn'] as String),
      );
}

class IncidenciaCategoriaModel {
  final String categoria;
  final int total;
  final int abiertas;
  final int resueltas;
  final int vencidas;

  const IncidenciaCategoriaModel({
    required this.categoria,
    required this.total,
    required this.abiertas,
    required this.resueltas,
    required this.vencidas,
  });

  factory IncidenciaCategoriaModel.fromJson(Map<String, dynamic> j) =>
      IncidenciaCategoriaModel(
        categoria: j['categoria'] as String,
        total: j['total'] as int,
        abiertas: j['abiertas'] as int,
        resueltas: j['resueltas'] as int,
        vencidas: j['vencidas'] as int,
      );
}

class VisitadorEficienciaModel {
  final String visitadorId;
  final String nombreCompleto;
  final int visitasCompletadas;
  final int visitasAgendadas;
  final double porcentajeCumplimiento;
  final int novedadesRegistradas;
  final int novedadesResueltas;
  final double tiempoPromedioVisitaMinutos;

  const VisitadorEficienciaModel({
    required this.visitadorId,
    required this.nombreCompleto,
    required this.visitasCompletadas,
    required this.visitasAgendadas,
    required this.porcentajeCumplimiento,
    required this.novedadesRegistradas,
    required this.novedadesResueltas,
    required this.tiempoPromedioVisitaMinutos,
  });

  factory VisitadorEficienciaModel.fromJson(Map<String, dynamic> j) =>
      VisitadorEficienciaModel(
        visitadorId: j['visitadorId'] as String,
        nombreCompleto: j['nombreCompleto'] as String,
        visitasCompletadas: j['visitasCompletadas'] as int,
        visitasAgendadas: j['visitasAgendadas'] as int,
        porcentajeCumplimiento:
            (j['porcentajeCumplimiento'] as num).toDouble(),
        novedadesRegistradas: j['novedadesRegistradas'] as int,
        novedadesResueltas: j['novedadesResueltas'] as int,
        tiempoPromedioVisitaMinutos:
            (j['tiempoPromedioVisitaMinutos'] as num).toDouble(),
      );
}

class HeatmapPuntoModel {
  final String nombrePdv;
  final double latitud;
  final double longitud;
  final int cantidadVisitas;
  final int novedadesAbiertas;

  const HeatmapPuntoModel({
    required this.nombrePdv,
    required this.latitud,
    required this.longitud,
    required this.cantidadVisitas,
    required this.novedadesAbiertas,
  });

  factory HeatmapPuntoModel.fromJson(Map<String, dynamic> j) =>
      HeatmapPuntoModel(
        nombrePdv: j['nombrePdv'] as String,
        latitud: (j['latitud'] as num).toDouble(),
        longitud: (j['longitud'] as num).toDouble(),
        cantidadVisitas: j['cantidadVisitas'] as int,
        novedadesAbiertas: j['novedadesAbiertas'] as int,
      );
}

class AlertaDashboardModel {
  final String novedadId;
  final String titulo;
  final String categoria;
  final String prioridad;
  final DateTime fechaSeguimiento;
  final int diasVencida;
  final String nombrePdv;
  final String responsableNombre;

  const AlertaDashboardModel({
    required this.novedadId,
    required this.titulo,
    required this.categoria,
    required this.prioridad,
    required this.fechaSeguimiento,
    required this.diasVencida,
    required this.nombrePdv,
    required this.responsableNombre,
  });

  factory AlertaDashboardModel.fromJson(Map<String, dynamic> j) =>
      AlertaDashboardModel(
        novedadId: j['novedadId'] as String,
        titulo: j['titulo'] as String,
        categoria: j['categoria'] as String,
        prioridad: j['prioridad'] as String,
        fechaSeguimiento: DateTime.parse(j['fechaSeguimiento'] as String),
        diasVencida: j['diasVencida'] as int,
        nombrePdv: j['nombrePdv'] as String,
        responsableNombre: j['responsableNombre'] as String,
      );
}

class NovedadesTimelineModel {
  final DateTime fecha;
  final int abiertas;
  final int enProgreso;
  final int resueltas;
  final int cerradas;

  const NovedadesTimelineModel({
    required this.fecha,
    required this.abiertas,
    required this.enProgreso,
    required this.resueltas,
    required this.cerradas,
  });

  factory NovedadesTimelineModel.fromJson(Map<String, dynamic> j) =>
      NovedadesTimelineModel(
        fecha: DateTime.parse(j['fecha'] as String),
        abiertas: j['abiertas'] as int,
        enProgreso: j['enProgreso'] as int,
        resueltas: j['resueltas'] as int,
        cerradas: j['cerradas'] as int,
      );
}

class DashboardResumenModel {
  final DateTime desde;
  final DateTime hasta;
  final DashboardKpiModel kpis;
  final List<IncidenciaCategoriaModel> incidenciasPorCategoria;
  final List<VisitadorEficienciaModel> eficienciaPorVisitador;
  final List<HeatmapPuntoModel> heatmap;
  final List<AlertaDashboardModel> alertasActivas;
  final List<NovedadesTimelineModel> timeline;

  const DashboardResumenModel({
    required this.desde,
    required this.hasta,
    required this.kpis,
    required this.incidenciasPorCategoria,
    required this.eficienciaPorVisitador,
    required this.heatmap,
    required this.alertasActivas,
    required this.timeline,
  });

  factory DashboardResumenModel.fromJson(Map<String, dynamic> j) =>
      DashboardResumenModel(
        desde: DateTime.parse(j['desde'] as String),
        hasta: DateTime.parse(j['hasta'] as String),
        kpis: DashboardKpiModel.fromJson(j['kpis'] as Map<String, dynamic>),
        incidenciasPorCategoria: (j['incidenciasPorCategoria'] as List)
            .map((e) =>
                IncidenciaCategoriaModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        eficienciaPorVisitador: (j['eficienciaPorVisitador'] as List)
            .map((e) =>
                VisitadorEficienciaModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        heatmap: (j['heatmap'] as List)
            .map((e) => HeatmapPuntoModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        alertasActivas: (j['alertasActivas'] as List)
            .map((e) =>
                AlertaDashboardModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        timeline: (j['timeline'] as List)
            .map((e) =>
                NovedadesTimelineModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
