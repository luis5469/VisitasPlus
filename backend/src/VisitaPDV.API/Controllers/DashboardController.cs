using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Application.Features.Dashboard.Dtos;
using VisitaPDV.Application.Features.Dashboard.Queries;

namespace VisitaPDV.API.Controllers;

/// <summary>Dashboard analítico ejecutivo.</summary>
[Authorize]
public sealed class DashboardController : BaseApiController
{
    /// <summary>
    /// Resumen completo del dashboard: KPIs, incidencias por categoría,
    /// eficiencia por visitador, heatmap, alertas y timeline.
    /// Respuesta cacheada 5 minutos en Redis.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<DashboardResumenDto>), 200)]
    public async Task<IActionResult> GetResumen(
        [FromQuery] DateTime? desde,
        [FromQuery] DateTime? hasta,
        CancellationToken ct)
    {
        var result = await Mediator.Send(new GetDashboardResumenQuery(desde, hasta), ct);
        return Ok(ApiResponse<DashboardResumenDto>.Ok(result));
    }

    /// <summary>
    /// Exporta el dashboard. Formato: <c>pdf</c> o <c>excel</c>.
    /// </summary>
    [HttpGet("exportar")]
    [ProducesResponseType(typeof(FileContentResult), 200)]
    public async Task<IActionResult> Exportar(
        [FromQuery] string formato = "pdf",
        [FromQuery] DateTime? desde = null,
        [FromQuery] DateTime? hasta = null,
        CancellationToken ct = default)
    {
        var result = await Mediator.Send(new ExportDashboardQuery(formato, desde, hasta), ct);
        return File(result.Contenido, result.ContentType, result.NombreArchivo);
    }
}
