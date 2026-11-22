using MediatR;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Application.Features.Novedades.Commands;

public record AnalizarNovedadCommand(string Descripcion) : IRequest<NovedadAnalisisResult>;
