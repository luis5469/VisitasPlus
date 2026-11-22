using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IRefreshTokenRepository
{
    Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken ct = default);
    Task<RefreshToken?> GetActiveByUsuarioAsync(string usuarioId, CancellationToken ct = default);
    Task AddAsync(RefreshToken token, CancellationToken ct = default);
    Task RevokeAllByUsuarioAsync(string usuarioId, string reason, CancellationToken ct = default);
}
