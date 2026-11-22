namespace VisitaPDV.Application.Features.Dashboard.Dtos;

public record DashboardKpiDto(
    int NovedadesAbiertas,
    int NovedadesVencidas,
    double TiempoResolucionPromedioHoras,
    int VisitasEjecutadas,
    double PorcentajeCumplimientoAgenda,
    int TotalAgendado,
    int TotalNovedades,
    DateTime GeneradoEn
);

public record IncidenciaCategoriaDto(
    string Categoria,
    int Total,
    int Abiertas,
    int Resueltas,
    int Vencidas
);

public record VisitadorEficienciaDto(
    string VisitadorId,
    string NombreCompleto,
    int VisitasCompletadas,
    int VisitasAgendadas,
    double PorcentajeCumplimiento,
    int NovedadesRegistradas,
    int NovedadesResueltas,
    double TiempoPromedioVisitaMinutos
);

public record HeatmapPuntoDto(
    string NombrePdv,
    double Latitud,
    double Longitud,
    int CantidadVisitas,
    int NovedadesAbiertas
);

public record AlertaDashboardDto(
    string NovedadId,
    string Titulo,
    string Categoria,
    string Prioridad,
    DateTime FechaSeguimiento,
    int DiasVencida,
    string NombrePdv,
    string ResponsableNombre
);

public record NovedadesTimelineDto(
    DateTime Fecha,
    int Abiertas,
    int EnProgreso,
    int Resueltas,
    int Cerradas
);

public record DashboardResumenDto(
    DateTime Desde,
    DateTime Hasta,
    DashboardKpiDto Kpis,
    IEnumerable<IncidenciaCategoriaDto> IncidenciasPorCategoria,
    IEnumerable<VisitadorEficienciaDto> EficienciaPorVisitador,
    IEnumerable<HeatmapPuntoDto> Heatmap,
    IEnumerable<AlertaDashboardDto> AlertasActivas,
    IEnumerable<NovedadesTimelineDto> Timeline
);

public record ExportResultDto(
    byte[] Contenido,
    string ContentType,
    string NombreArchivo
);
