using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Dashboard.Dtos;
using VisitaPDV.Application.Features.Dashboard.Queries;

namespace VisitaPDV.Application.Features.Dashboard.Handlers;

public sealed class GetDashboardResumenQueryHandler(
    IDashboardRepository dashboardRepo,
    ICacheService cache)
    : IRequestHandler<GetDashboardResumenQuery, DashboardResumenDto>
{
    private static readonly TimeSpan CacheExpiry = TimeSpan.FromMinutes(5);

    public async Task<DashboardResumenDto> Handle(
        GetDashboardResumenQuery request, CancellationToken cancellationToken)
    {
        var desde = DateTime.SpecifyKind(request.Desde ?? DateTime.UtcNow.AddDays(-30), DateTimeKind.Utc);
        var hasta = DateTime.SpecifyKind(request.Hasta ?? DateTime.UtcNow, DateTimeKind.Utc);

        var cacheKey = $"dashboard:resumen:{desde:yyyyMMdd}:{hasta:yyyyMMdd}";
        var cached   = await cache.GetAsync<DashboardResumenDto>(cacheKey, cancellationToken);
        if (cached is not null)
            return cached;

        var kpis = await dashboardRepo.GetKpisAsync(desde, hasta, cancellationToken);
        var categorias = await dashboardRepo.GetIncidenciasPorCategoriaAsync(desde, hasta, cancellationToken);
        var eficiencia = await dashboardRepo.GetEficienciaPorVisitadorAsync(desde, hasta, cancellationToken);
        var heatmap = await dashboardRepo.GetHeatmapPuntosAsync(desde, hasta, cancellationToken);
        var alertas = await dashboardRepo.GetAlertasActivasAsync(cancellationToken);
        var timeline = await dashboardRepo.GetNovedadesTimelineAsync(desde, hasta, cancellationToken);

        var resultado = new DashboardResumenDto(
            Desde:                  desde,
            Hasta:                  hasta,
            Kpis:                   kpis,
            IncidenciasPorCategoria: categorias,
            EficienciaPorVisitador: eficiencia,
            Heatmap:                heatmap,
            AlertasActivas:         alertas,
            Timeline:               timeline
        );

        await cache.SetAsync(cacheKey, resultado, CacheExpiry, cancellationToken);
        return resultado;
    }
}

public sealed class ExportDashboardQueryHandler(
    IDashboardRepository dashboardRepo,
    IExportService exportService)
    : IRequestHandler<ExportDashboardQuery, ExportResultDto>
{
    public async Task<ExportResultDto> Handle(
        ExportDashboardQuery request, CancellationToken cancellationToken)
    {
        var desde = DateTime.SpecifyKind(request.Desde ?? DateTime.UtcNow.AddDays(-30), DateTimeKind.Utc);
        var hasta = DateTime.SpecifyKind(request.Hasta ?? DateTime.UtcNow, DateTimeKind.Utc);

        var kpis = await dashboardRepo.GetKpisAsync(desde, hasta, cancellationToken);
        var categorias = await dashboardRepo.GetIncidenciasPorCategoriaAsync(desde, hasta, cancellationToken);
        var eficiencia = await dashboardRepo.GetEficienciaPorVisitadorAsync(desde, hasta, cancellationToken);
        var heatmap = await dashboardRepo.GetHeatmapPuntosAsync(desde, hasta, cancellationToken);
        var alertas = await dashboardRepo.GetAlertasActivasAsync(cancellationToken);
        var timeline = await dashboardRepo.GetNovedadesTimelineAsync(desde, hasta, cancellationToken);

        var data = new DashboardResumenDto(
            Desde:                  desde,
            Hasta:                  hasta,
            Kpis:                   kpis,
            IncidenciasPorCategoria: categorias,
            EficienciaPorVisitador: eficiencia,
            Heatmap:                heatmap,
            AlertasActivas:         alertas,
            Timeline:               timeline
        );

        return request.Formato.ToLowerInvariant() switch
        {
            "excel" => await exportService.ExportDashboardToExcelAsync(data, cancellationToken),
            _       => await exportService.ExportDashboardToPdfAsync(data, cancellationToken)
        };
    }
}
