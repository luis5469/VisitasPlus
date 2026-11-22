using Microsoft.EntityFrameworkCore;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class RefreshTokenRepository(ApplicationDbContext context)
    : IRefreshTokenRepository
{
    public Task<RefreshToken?> GetByTokenAsync(string token, CancellationToken ct = default) =>
        context.Set<RefreshToken>()
            .Include(r => r.Usuario)
            .FirstOrDefaultAsync(r => r.Token == token, ct);

    public Task<RefreshToken?> GetActiveByUsuarioAsync(
        string usuarioId, CancellationToken ct = default) =>
        context.Set<RefreshToken>()
            .Where(r => r.UsuarioId == usuarioId && !r.IsRevoked && !r.IsUsed
                        && r.ExpiresAt > DateTime.UtcNow)
            .FirstOrDefaultAsync(ct);

    public async Task AddAsync(RefreshToken token, CancellationToken ct = default) =>
        await context.Set<RefreshToken>().AddAsync(token, ct);

    public async Task RevokeAllByUsuarioAsync(
        string usuarioId, string reason, CancellationToken ct = default)
    {
        var tokens = await context.Set<RefreshToken>()
            .Where(r => r.UsuarioId == usuarioId && !r.IsRevoked && !r.IsUsed
                        && r.ExpiresAt > DateTime.UtcNow)
            .ToListAsync(ct);

        foreach (var t in tokens)
            t.Revoke(reason);
    }
}
