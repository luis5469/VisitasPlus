using VisitaPDV.Application.Features.Dashboard.Dtos;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IExportService
{
    Task<ExportResultDto> ExportDashboardToPdfAsync(DashboardResumenDto data, CancellationToken ct = default);
    Task<ExportResultDto> ExportDashboardToExcelAsync(DashboardResumenDto data, CancellationToken ct = default);
}
