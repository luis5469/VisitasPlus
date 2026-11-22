using VisitaPDV.Application.Features.Dashboard.Dtos;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IDashboardRepository
{
    Task<DashboardKpiDto> GetKpisAsync(DateTime desde, DateTime hasta, CancellationToken ct = default);

    Task<IEnumerable<IncidenciaCategoriaDto>> GetIncidenciasPorCategoriaAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default);

    Task<IEnumerable<VisitadorEficienciaDto>> GetEficienciaPorVisitadorAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default);

    Task<IEnumerable<HeatmapPuntoDto>> GetHeatmapPuntosAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default);

    Task<IEnumerable<AlertaDashboardDto>> GetAlertasActivasAsync(CancellationToken ct = default);

    Task<IEnumerable<NovedadesTimelineDto>> GetNovedadesTimelineAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default);
}
