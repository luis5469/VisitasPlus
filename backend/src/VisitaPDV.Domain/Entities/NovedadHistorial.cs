using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Domain.Entities;

public class NovedadHistorial : BaseEntity
{
    public string NovedadId { get; private set; } = string.Empty;
    public NovedadStatus EstadoAnterior { get; private set; }
    public NovedadStatus EstadoNuevo { get; private set; }
    public string Comentario { get; private set; } = string.Empty;
    public string UsuarioId { get; private set; } = string.Empty;

    protected NovedadHistorial() { }

    public static NovedadHistorial Create(
        string novedadId, NovedadStatus anterior,
        NovedadStatus nuevo, string usuarioId, string comentario) =>
        new()
        {
            NovedadId = novedadId,
            EstadoAnterior = anterior,
            EstadoNuevo = nuevo,
            UsuarioId = usuarioId,
            Comentario = comentario
        };
}
