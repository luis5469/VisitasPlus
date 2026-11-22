using System.Threading;
using System.Threading.Tasks;

namespace VisitaPDV.Application.Common.Interfaces;

/// <summary>
/// Servicio para la gobernanza y privacidad de datos bajo la LOPDP de Ecuador.
/// Permite anonimizar activamente datos personales de textos registrados en las visitas.
/// </summary>
public interface IAnonymizationService
{
    /// <summary>
    /// Identifica y anonimiza información personal identificable (PII) como cédulas, teléfonos, correos y nombres en un texto.
    /// </summary>
    /// <param name="text">El texto original a procesar.</param>
    /// <param name="ct">Token de cancelación.</param>
    /// <returns>El texto con los datos personales anonimizados con marcadores como [CEDULA_ANONIMIZADA].</returns>
    Task<string> AnonymizeTextAsync(string? text, CancellationToken ct = default);
}
