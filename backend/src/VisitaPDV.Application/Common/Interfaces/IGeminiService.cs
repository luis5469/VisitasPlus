using System.Threading;
using System.Threading.Tasks;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IGeminiService
{
    Task<NovedadAnalisisResult> AnalizarNovedadAsync(string descripcion, CancellationToken ct = default);
    Task<string> AnonimizarTextoAsync(string texto, CancellationToken ct = default);
}

public record NovedadAnalisisResult(
    string Categoria,
    string Prioridad,
    string TituloSugerido,
    string Justificacion
);
