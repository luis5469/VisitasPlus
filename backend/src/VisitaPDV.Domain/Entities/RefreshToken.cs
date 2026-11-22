using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Exceptions;

namespace VisitaPDV.Domain.Entities;

public class RefreshToken : BaseEntity
{
    public string UsuarioId { get; private set; } = string.Empty;
    public string Token { get; private set; } = string.Empty;
    public string JwtId { get; private set; } = string.Empty;
    public DateTime ExpiresAt { get; private set; }
    public bool IsUsed { get; private set; }
    public bool IsRevoked { get; private set; }
    public string? RevokedReason { get; private set; }
    public DateTime? RevokedAt { get; private set; }
    public string? IpAddress { get; private set; }
    public string? UserAgent { get; private set; }
    public string? DispositivoId { get; private set; }

    public Usuario Usuario { get; private set; } = null!;
    public Dispositivo? Dispositivo { get; private set; }

    protected RefreshToken() { }

    public static RefreshToken Create(
        string usuarioId,
        string token,
        string jwtId,
        DateTime expiresAt,
        string? ipAddress = null,
        string? userAgent = null,
        string? dispositivoId = null) =>
        new()
        {
            UsuarioId = usuarioId,
            Token = token,
            JwtId = jwtId,
            ExpiresAt = expiresAt,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            DispositivoId = dispositivoId
        };

    public bool IsActive() => !IsRevoked && !IsUsed && ExpiresAt > DateTime.UtcNow;

    public void MarkAsUsed()
    {
        if (!IsActive())
            throw new DomainException("El token de refresco ya no es válido.");
        IsUsed = true;
    }

    public void Revoke(string reason = "Revocado manualmente")
    {
        IsRevoked = true;
        RevokedReason = reason;
        RevokedAt = DateTime.UtcNow;
    }
}
