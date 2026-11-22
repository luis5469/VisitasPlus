using VisitaPDV.Application.Features.Novedades.Dtos;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Features.Novedades.Handlers;

/// <summary>Mapper compartido entre command y query handlers.</summary>
internal static class NovedadMapper
{
    internal static NovedadDto ToDto(Novedad n) => new(
        n.Id, n.VisitaId, n.PdvId,
        n.Titulo, n.Descripcion, n.Categoria, n.Prioridad,
        n.Estado.ToString(),
        n.ResponsableSolucionId, n.ResponsableSeguimientoId,
        n.FechaSeguimiento, n.Sincronizado,
        n.CreatedAt,
        n.Imagenes.Select(i => new NovedadImagenDto(
            i.Id, i.UrlImagen, i.NombreArchivo, i.TamanoBytes,
            i.MarcaAguaAplicada, i.Latitud, i.Longitud, i.TimestampCaptura)).ToList(),
        n.Historial.Select(h => new NovedadHistorialDto(
            h.Id, h.EstadoAnterior.ToString(), h.EstadoNuevo.ToString(),
            h.Comentario, h.UsuarioId, h.CreatedAt)).ToList()
    );

    internal static NovedadListDto ToListDto(Novedad n) => new(
        n.Id, n.PdvId, n.Titulo, n.Categoria, n.Prioridad,
        n.Estado.ToString(), n.FechaSeguimiento,
        n.Imagenes?.Count ?? 0, n.CreatedAt);
}
