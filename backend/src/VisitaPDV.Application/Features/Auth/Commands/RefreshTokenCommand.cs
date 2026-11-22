using MediatR;
using VisitaPDV.Application.Features.Auth.Dtos;

namespace VisitaPDV.Application.Features.Auth.Commands;

public record RefreshTokenCommand(
    string AccessToken,
    string RefreshToken,
    string? IpAddress = null,
    string? UserAgent = null)
    : IRequest<LoginResponse>;
