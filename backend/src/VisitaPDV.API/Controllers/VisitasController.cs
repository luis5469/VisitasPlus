using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Application.Features.Visitas.Commands;
using VisitaPDV.Application.Features.Visitas.Dtos;
using VisitaPDV.Application.Features.Visitas.Queries;

namespace VisitaPDV.API.Controllers;

[Authorize]
public sealed class VisitasController(ICurrentUserService currentUser) : BaseApiController
{
    /// <summary>Historial de visitas del usuario autenticado.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<VisitaDto>>), 200)]
    public async Task<IActionResult> GetVisitas(CancellationToken ct)
    {
        var result = await Mediator.Send(new GetVisitasQuery(currentUser.UserId), ct);
        return Ok(ApiResponse<IEnumerable<VisitaDto>>.Ok(result));
    }

    /// <summary>Iniciar una visita a un PDV (valida geofence y visita activa).</summary>
    [HttpPost("iniciar")]
    [ProducesResponseType(typeof(ApiResponse<VisitaDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse), 400)]
    public async Task<IActionResult> IniciarVisita(
        [FromBody] IniciarVisitaRequest req, CancellationToken ct)
    {
        try
        {
            var cmd    = new IniciarVisitaCommand(req.PdvId, req.Latitud, req.Longitud, currentUser.UserId);
            var result = await Mediator.Send(cmd, ct);
            return Ok(ApiResponse<VisitaDto>.Ok(result, "Visita iniciada correctamente."));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse.Fail(ex.Message));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
    }

    /// <summary>Finalizar una visita en curso.</summary>
    [HttpPost("finalizar")]
    [ProducesResponseType(typeof(ApiResponse<VisitaDto>), 200)]
    [ProducesResponseType(typeof(ApiResponse), 400)]
    public async Task<IActionResult> FinalizarVisita(
        [FromBody] FinalizarVisitaRequest req, CancellationToken ct)
    {
        try
        {
            var cmd    = new FinalizarVisitaCommand(req.VisitaId, req.Latitud, req.Longitud, currentUser.UserId);
            var result = await Mediator.Send(cmd, ct);
            return Ok(ApiResponse<VisitaDto>.Ok(result, "Visita finalizada correctamente."));
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(ApiResponse.Fail(ex.Message));
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(ApiResponse.Fail(ex.Message));
        }
    }
}
