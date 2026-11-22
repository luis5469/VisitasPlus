using MediatR;
using VisitaPDV.Application.Features.Visitas.Dtos;

namespace VisitaPDV.Application.Features.Visitas.Commands;

public record IniciarVisitaCommand(
    string  PdvId,
    decimal Latitud,
    decimal Longitud,
    string  VisitadorId)
    : IRequest<VisitaDto>;

public record FinalizarVisitaCommand(
    string  VisitaId,
    decimal Latitud,
    decimal Longitud,
    string  VisitadorId)
    : IRequest<VisitaDto>;
