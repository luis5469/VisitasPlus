namespace VisitaPDV.Application.Features.Auth.Dtos;

public record LoginRequest(
    string UsernameOrEmail,
    string Password,
    string? DeviceId = null,
    string? DeviceName = null,
    string? Plataforma = null);

public record LoginResponse(
    string AccessToken,
    string RefreshToken,
    DateTime ExpiresAt,
    string UserId,
    string Username,
    string NombreCompleto,
    string Rol);

public record RefreshTokenRequest(
    string AccessToken,
    string RefreshToken);

public record RevokeTokenRequest(
    string RefreshToken);

public record MeResponse(
    string Id,
    string Username,
    string NombreCompleto,
    string Email,
    string Rol,
    DateTime? UltimoLogin,
    bool BiometriaHabilitada);
