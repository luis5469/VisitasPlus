using MediatR;
using VisitaPDV.Application.Features.Auth.Dtos;

namespace VisitaPDV.Application.Features.Auth.Queries;

public record GetMeQuery(string UsuarioId) : IRequest<MeResponse>;
