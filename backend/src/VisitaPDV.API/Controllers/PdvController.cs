using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Application.Features.Visitas.Dtos;
using VisitaPDV.Application.Features.Visitas.Queries;

namespace VisitaPDV.API.Controllers;

[Authorize]
public sealed class PdvController : BaseApiController
{
    /// <summary>Lista todos los PDV activos.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<PdvDto>>), 200)]
    public async Task<IActionResult> GetPdvs(CancellationToken ct)
    {
        var result = await Mediator.Send(new GetPdvsQuery(), ct);
        return Ok(ApiResponse<IEnumerable<PdvDto>>.Ok(result));
    }

    /// <summary>Obtiene un PDV por ID.</summary>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(ApiResponse<PdvDto>), 200)]
    [ProducesResponseType(404)]
    public async Task<IActionResult> GetPdv(string id, CancellationToken ct)
    {
        var result = await Mediator.Send(new GetPdvByIdQuery(id), ct);
        if (result is null)
            return NotFound(ApiResponse.Fail("PDV no encontrado."));
        return Ok(ApiResponse<PdvDto>.Ok(result));
    }
}
