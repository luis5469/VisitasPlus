namespace VisitaPDV.Application.Features.Visitas.Dtos;

public record PdvDto(
    string  Id,
    string  Codigo,
    string  Nombre,
    string  Direccion,
    string  Ciudad,
    string? Zona,
    string? Responsable,
    string? Telefono,
    decimal Latitud,
    decimal Longitud,
    int     GeofenceMetros,
    bool    Activo);

public record VisitaDto(
    string   Id,
    string   PdvId,
    string   PdvNombre,
    string   PdvCodigo,
    string   VisitadorId,
    string   VisitadorNombre,
    string   Estado,
    decimal? LatitudInicio,
    decimal? LongitudInicio,
    decimal? LatitudFin,
    decimal? LongitudFin,
    DateTime TimestampInicio,
    DateTime? TimestampFin,
    string?  ActaPdfUrl,
    bool     Sincronizado);

public record IniciarVisitaRequest(
    string  PdvId,
    decimal Latitud,
    decimal Longitud);

public record FinalizarVisitaRequest(
    string  VisitaId,
    decimal Latitud,
    decimal Longitud);
