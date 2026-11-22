using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Application.Features.Novedades.Commands;
using VisitaPDV.Application.Features.Novedades.Dtos;
using VisitaPDV.Application.Features.Novedades.Queries;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Exceptions;

namespace VisitaPDV.API.Controllers;

/// <summary>CRUD completo para el módulo de Novedades.</summary>
[Authorize]
public sealed class NovedadesController(ICurrentUserService currentUser) : BaseApiController
{
    // ────────────────────────── GET ──────────────────────────────────────────

    /// <summary>Lista paginada de novedades con filtros opcionales.</summary>
    [HttpGet]
    public async Task<IActionResult> GetNovedades(
        [FromQuery] string? estado,
        [FromQuery] string? categoria,
        [FromQuery] string? prioridad,
        [FromQuery] string? pdvId,
        [FromQuery] string? responsableId,
        [FromQuery] DateTime? desde,
        [FromQuery] DateTime? hasta,
        [FromQuery] int pagina = 1,
        [FromQuery] int tamano = 20,
        CancellationToken ct = default)
    {
        NovedadStatus? estadoEnum = null;
        if (!string.IsNullOrWhiteSpace(estado) && Enum.TryParse<NovedadStatus>(estado, true, out var e))
            estadoEnum = e;

        var result = await Mediator.Send(new GetNovedadesPagedQuery(
            estadoEnum, categoria, prioridad, pdvId, responsableId,
            desde, hasta, pagina, tamano), ct);

        return Ok(ApiResponse<NovedadesPagedResponse>.Ok(result));
    }

    /// <summary>Obtiene una novedad con detalle completo (imágenes + historial).</summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetNovedad(string id, CancellationToken ct)
    {
        var result = await Mediator.Send(new GetNovedadByIdQuery(id), ct);
        return result is null
            ? NotFound(ApiResponse.Fail($"Novedad {id} no encontrada."))
            : Ok(ApiResponse<NovedadDto>.Ok(result));
    }

    /// <summary>Novedades de una visita específica.</summary>
    [HttpGet("visita/{visitaId}")]
    public async Task<IActionResult> GetByVisita(string visitaId, CancellationToken ct)
    {
        var result = await Mediator.Send(new GetNovedadesByVisitaQuery(visitaId), ct);
        return Ok(ApiResponse<List<NovedadListDto>>.Ok(result));
    }

    /// <summary>Novedades de un PDV específico.</summary>
    [HttpGet("pdv/{pdvId}")]
    public async Task<IActionResult> GetByPdv(string pdvId, CancellationToken ct)
    {
        var result = await Mediator.Send(new GetNovedadesByPdvQuery(pdvId), ct);
        return Ok(ApiResponse<List<NovedadListDto>>.Ok(result));
    }

    /// <summary>Novedades asignadas al usuario autenticado.</summary>
    [HttpGet("mis-novedades")]
    public async Task<IActionResult> GetMisNovedades(CancellationToken ct)
    {
        var result = await Mediator.Send(new GetNovedadesByResponsableQuery(currentUser.UserId), ct);
        return Ok(ApiResponse<List<NovedadListDto>>.Ok(result));
    }

    /// <summary>Novedades vencidas (fecha seguimiento pasada, no resueltas).</summary>
    [HttpGet("vencidas")]
    public async Task<IActionResult> GetVencidas(CancellationToken ct)
    {
        var result = await Mediator.Send(new GetNovedadesVencidasQuery(), ct);
        return Ok(ApiResponse<List<NovedadListDto>>.Ok(result));
    }

    // ────────────────────────── POST ─────────────────────────────────────────

    /// <summary>Crea una nueva novedad.</summary>
    [HttpPost]
    public async Task<IActionResult> CrearNovedad(
        [FromBody] CrearNovedadRequest req, CancellationToken ct)
    {
        var cmd = new CrearNovedadCommand(
            req.VisitaId, req.PdvId, req.Titulo, req.Descripcion,
            req.Categoria, req.Prioridad,
            req.ResponsableSolucionId, req.ResponsableSeguimientoId,
            req.FechaSeguimiento);

        var result = await Mediator.Send(cmd, ct);
        return CreatedAtAction(nameof(GetNovedad), new { id = result.Id },
            ApiResponse<NovedadDto>.Ok(result, "Novedad creada exitosamente."));
    }

    /// <summary>Interpreta y clasifica una descripción de novedad usando Inteligencia Artificial.</summary>
    [HttpPost("analizar-ia")]
    public async Task<IActionResult> AnalizarNovedadConIA(
        [FromBody] AnalizarNovedadRequest req, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(req.Descripcion))
            return BadRequest(ApiResponse.Fail("La descripción no puede estar vacía."));

        try
        {
            var result = await Mediator.Send(new AnalizarNovedadCommand(req.Descripcion), ct);
            return Ok(ApiResponse<NovedadAnalisisResult>.Ok(result, "Análisis de IA completado exitosamente."));
        }
        catch (System.InvalidOperationException ex)
        {
            return StatusCode(503, ApiResponse.Fail(ex.Message));
        }
        catch (System.Exception ex)
        {
            return StatusCode(500, ApiResponse.Fail($"Error al procesar el análisis de IA: {ex.Message}"));
        }
    }

    // ────────────────────────── PUT ──────────────────────────────────────────

    /// <summary>Actualiza datos de una novedad.</summary>
    [HttpPut("{id}")]
    public async Task<IActionResult> ActualizarNovedad(
        string id, [FromBody] ActualizarNovedadRequest req, CancellationToken ct)
    {
        try
        {
            var cmd = new ActualizarNovedadCommand(
                id, req.Titulo, req.Descripcion, req.Categoria, req.Prioridad,
                req.ResponsableSolucionId, req.ResponsableSeguimientoId, req.FechaSeguimiento);
            var result = await Mediator.Send(cmd, ct);
            return Ok(ApiResponse<NovedadDto>.Ok(result));
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
    }

    /// <summary>Cambia el estado de una novedad.</summary>
    [HttpPatch("{id}/estado")]
    public async Task<IActionResult> CambiarEstado(
        string id, [FromBody] CambiarEstadoRequest req, CancellationToken ct)
    {
        try
        {
            var result = await Mediator.Send(
                new CambiarEstadoNovedadCommand(id, req.NuevoEstado, req.Comentario), ct);
            return Ok(ApiResponse<NovedadDto>.Ok(result, "Estado actualizado."));
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
        catch (DomainException ex)   { return BadRequest(ApiResponse.Fail(ex.Message)); }
    }

    // ────────────────────────── DELETE ───────────────────────────────────────

    /// <summary>Elimina una novedad (soft delete lógico vía repository).</summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> EliminarNovedad(string id, CancellationToken ct)
    {
        try
        {
            await Mediator.Send(new EliminarNovedadCommand(id), ct);
            return NoContent();
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
    }

    // ────────────────────────── IMÁGENES ─────────────────────────────────────

    /// <summary>Sube una imagen a la novedad. Acepta multipart/form-data.</summary>
    [HttpPost("{id}/imagenes")]
    [RequestSizeLimit(15 * 1024 * 1024)] // 15 MB max en HTTP
    public async Task<IActionResult> SubirImagen(
        string id,
        IFormFile archivo,
        [FromForm] decimal? latitud,
        [FromForm] decimal? longitud,
        CancellationToken ct)
    {
        if (archivo is null || archivo.Length == 0)
            return BadRequest(ApiResponse.Fail("No se recibió ningún archivo."));

        using var stream = archivo.OpenReadStream();
        var cmd = new SubirImagenNovedadCommand(
            id, stream, archivo.FileName, archivo.ContentType, latitud, longitud);

        try
        {
            var result = await Mediator.Send(cmd, ct);
            return Ok(ApiResponse<SubirImagenResponse>.Ok(result, "Imagen subida exitosamente."));
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
        catch (DomainException ex)   { return BadRequest(ApiResponse.Fail(ex.Message)); }
    }

    /// <summary>Genera URL firmada (SAS) temporal para ver una imagen.</summary>
    [HttpGet("{id}/imagenes/{imagenId}/sas")]
    public async Task<IActionResult> GetSasUrl(
        string id, string imagenId,
        [FromQuery] int validMinutes = 60,
        CancellationToken ct = default)
    {
        try
        {
            var url = await Mediator.Send(new GetSasUrlImagenQuery(id, imagenId, validMinutes), ct);
            return Ok(ApiResponse<string>.Ok(url));
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
    }

    /// <summary>Elimina una imagen de la novedad y del blob storage.</summary>
    [HttpDelete("{id}/imagenes/{imagenId}")]
    public async Task<IActionResult> EliminarImagen(string id, string imagenId, CancellationToken ct)
    {
        try
        {
            await Mediator.Send(new EliminarImagenNovedadCommand(id, imagenId), ct);
            return NoContent();
        }
        catch (NotFoundException ex) { return NotFound(ApiResponse.Fail(ex.Message)); }
    }
}
