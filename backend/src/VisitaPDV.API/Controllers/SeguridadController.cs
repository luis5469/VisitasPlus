using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Common.Models;

namespace VisitaPDV.API.Controllers;

/// <summary>
/// Controlador para gobernanza de datos, seguridad y cumplimiento LOPDP.
/// </summary>
[Authorize]
public sealed class SeguridadController(IAnonymizationService anonymizer) : BaseApiController
{
    /// <summary>
    /// Anonimiza activamente un texto que contiene posibles datos personales (PII) bajo la LOPDP de Ecuador.
    /// </summary>
    [HttpPost("anonymize")]
    public async Task<IActionResult> AnonymizeText([FromBody] AnonymizeRequest request, CancellationToken ct)
    {
        if (string.IsNullOrWhiteSpace(request.Texto))
        {
            return BadRequest(ApiResponse.Fail("El texto a anonimizar no puede estar vacío."));
        }

        try
        {
            var textoAnonimizado = await anonymizer.AnonymizeTextAsync(request.Texto, ct);
            return Ok(ApiResponse<string>.Ok(textoAnonimizado, "Texto anonimizado exitosamente."));
        }
        catch (Exception ex)
        {
            return StatusCode(500, ApiResponse.Fail($"Error durante la anonimización activa: {ex.Message}"));
        }
    }
}

public class AnonymizeRequest
{
    public string Texto { get; set; } = string.Empty;
}
