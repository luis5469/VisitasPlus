using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Common.Interfaces;

public interface ITokenService
{
    /// <summary>Genera un JWT de acceso con expiración de 8h.</summary>
    string GenerateAccessToken(Usuario usuario, string jwtId);

    /// <summary>Genera un refresh token criptográficamente seguro.</summary>
    string GenerateRefreshToken();

    /// <summary>Valida un JWT expirado/válido y devuelve los claims.</summary>
    System.Security.Claims.ClaimsPrincipal? GetPrincipalFromToken(string token);

    string? GetUserIdFromToken(string token);
    string? GetJtiFromToken(string token);
}
