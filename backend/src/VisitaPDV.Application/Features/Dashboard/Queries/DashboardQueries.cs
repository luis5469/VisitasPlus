using MediatR;
using VisitaPDV.Application.Features.Dashboard.Dtos;

namespace VisitaPDV.Application.Features.Dashboard.Queries;

/// <summary>Obtiene el resumen ejecutivo del dashboard para el rango de fechas indicado.</summary>
public record GetDashboardResumenQuery(
    DateTime? Desde = null,
    DateTime? Hasta = null
) : IRequest<DashboardResumenDto>;

/// <summary>Exporta el dashboard en PDF o Excel.</summary>
public record ExportDashboardQuery(
    string Formato,         // "pdf" | "excel"
    DateTime? Desde = null,
    DateTime? Hasta = null
) : IRequest<ExportResultDto>;
