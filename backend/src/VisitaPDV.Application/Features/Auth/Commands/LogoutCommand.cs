using MediatR;

namespace VisitaPDV.Application.Features.Auth.Commands;

public record LogoutCommand(
    string RefreshToken,
    string UsuarioId,
    string? IpAddress = null,
    string? UserAgent = null)
    : IRequest<Unit>;
