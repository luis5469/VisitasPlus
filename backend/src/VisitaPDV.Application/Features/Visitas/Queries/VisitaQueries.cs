using MediatR;
using VisitaPDV.Application.Features.Visitas.Dtos;

namespace VisitaPDV.Application.Features.Visitas.Queries;

public record GetVisitasQuery(string VisitadorId) : IRequest<IEnumerable<VisitaDto>>;
public record GetPdvsQuery()                    : IRequest<IEnumerable<PdvDto>>;
public record GetPdvByIdQuery(string Id)          : IRequest<PdvDto?>;
