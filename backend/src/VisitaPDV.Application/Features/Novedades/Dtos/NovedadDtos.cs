using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Application.Features.Novedades.Dtos;

public record NovedadDto(
    string Id,
    string VisitaId,
    string PdvId,
    string Titulo,
    string Descripcion,
    string Categoria,
    string Prioridad,
    string Estado,
    string ResponsableSolucionId,
    string ResponsableSeguimientoId,
    DateTime FechaSeguimiento,
    bool Sincronizado,
    DateTime CreadoEn,
    List<NovedadImagenDto> Imagenes,
    List<NovedadHistorialDto> Historial
);

public record NovedadListDto(
    string Id,
    string PdvId,
    string Titulo,
    string Categoria,
    string Prioridad,
    string Estado,
    DateTime FechaSeguimiento,
    int TotalImagenes,
    DateTime CreadoEn
);

public record NovedadImagenDto(
    string Id,
    string UrlImagen,
    string NombreArchivo,
    long TamanoBytes,
    bool MarcaAguaAplicada,
    decimal? Latitud,
    decimal? Longitud,
    DateTime? TimestampCaptura
);

public record NovedadHistorialDto(
    string Id,
    string EstadoAnterior,
    string EstadoNuevo,
    string Comentario,
    string UsuarioId,
    DateTime CreadoEn
);

public record CrearNovedadRequest(
    string VisitaId,
    string PdvId,
    string Titulo,
    string Descripcion,
    string Categoria,
    string Prioridad,
    string ResponsableSolucionId,
    string ResponsableSeguimientoId,
    DateTime FechaSeguimiento
);

public record ActualizarNovedadRequest(
    string? Titulo,
    string? Descripcion,
    string? Categoria,
    string? Prioridad,
    string? ResponsableSolucionId,
    string? ResponsableSeguimientoId,
    DateTime? FechaSeguimiento
);

public record CambiarEstadoRequest(
    string NuevoEstado,
    string Comentario
);

public record SubirImagenResponse(
    string Id,
    string UrlImagen,
    string NombreArchivo,
    long TamanoBytes
);

public record NovedadesPagedResponse(
    List<NovedadListDto> Items,
    int TotalItems,
    int Pagina,
    int Tamano,
    int TotalPaginas
);

public record AnalizarNovedadRequest(
    string Descripcion
);
