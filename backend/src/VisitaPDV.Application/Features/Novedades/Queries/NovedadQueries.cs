using MediatR;
using VisitaPDV.Application.Features.Novedades.Dtos;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Application.Features.Novedades.Queries;

public record GetNovedadByIdQuery(string Id) : IRequest<NovedadDto?>;

public record GetNovedadesByVisitaQuery(string VisitaId) : IRequest<List<NovedadListDto>>;

public record GetNovedadesByPdvQuery(string PdvId) : IRequest<List<NovedadListDto>>;

public record GetNovedadesByResponsableQuery(string UsuarioId) : IRequest<List<NovedadListDto>>;

public record GetNovedadesVencidasQuery : IRequest<List<NovedadListDto>>;

public record GetNovedadesPagedQuery(
    NovedadStatus? Estado = null,
    string? Categoria = null,
    string? Prioridad = null,
    string? PdvId = null,
    string? ResponsableId = null,
    DateTime? Desde = null,
    DateTime? Hasta = null,
    int Pagina = 1,
    int Tamano = 20
) : IRequest<NovedadesPagedResponse>;

public record GetSasUrlImagenQuery(
    string NovedadId,
    string ImagenId,
    int ValidMinutes = 60
) : IRequest<string>;
