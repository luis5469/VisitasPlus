using MediatR;
using VisitaPDV.Application.Features.Auth.Dtos;

namespace VisitaPDV.Application.Features.Auth.Commands;

public record LoginCommand(
    string UsernameOrEmail,
    string Password,
    string? IpAddress = null,
    string? UserAgent = null,
    string? DeviceId = null,
    string? DeviceName = null,
    string? Plataforma = null)
    : IRequest<LoginResponse>;
