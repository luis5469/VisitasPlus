using MediatR;
using VisitaPDV.Application.Features.Novedades.Dtos;

namespace VisitaPDV.Application.Features.Novedades.Commands;

public record CrearNovedadCommand(
    string VisitaId,
    string PdvId,
    string Titulo,
    string Descripcion,
    string Categoria,
    string Prioridad,
    string ResponsableSolucionId,
    string ResponsableSeguimientoId,
    DateTime FechaSeguimiento
) : IRequest<NovedadDto>;

public record ActualizarNovedadCommand(
    string Id,
    string? Titulo,
    string? Descripcion,
    string? Categoria,
    string? Prioridad,
    string? ResponsableSolucionId,
    string? ResponsableSeguimientoId,
    DateTime? FechaSeguimiento
) : IRequest<NovedadDto>;

public record CambiarEstadoNovedadCommand(
    string NovedadId,
    string NuevoEstado,
    string Comentario
) : IRequest<NovedadDto>;

public record EliminarNovedadCommand(string Id) : IRequest<bool>;

public record SubirImagenNovedadCommand(
    string NovedadId,
    Stream ImagenStream,
    string NombreArchivo,
    string ContentType,
    decimal? Latitud,
    decimal? Longitud
) : IRequest<SubirImagenResponse>;

public record EliminarImagenNovedadCommand(
    string NovedadId,
    string ImagenId
) : IRequest<bool>;
