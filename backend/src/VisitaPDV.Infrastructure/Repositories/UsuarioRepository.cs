using Microsoft.EntityFrameworkCore;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class UsuarioRepository(ApplicationDbContext context) : IUsuarioRepository
{
    public Task<Usuario?> GetByIdAsync(string id, CancellationToken ct = default) =>
        context.Usuarios
            .Include(u => u.RefreshTokens)
            .Include(u => u.Dispositivos)
            .FirstOrDefaultAsync(u => u.Id == id, ct);

    public Task<Usuario?> GetByUsernameOrEmailAsync(
        string usernameOrEmail, CancellationToken ct = default)
    {
        var value = usernameOrEmail.Trim().ToLowerInvariant();
        return context.Usuarios
            .FirstOrDefaultAsync(
                u => u.Username == value || u.Email == value, ct);
    }

    public async Task AddAsync(Usuario usuario, CancellationToken ct = default) =>
        await context.Usuarios.AddAsync(usuario, ct);

    public void Update(Usuario usuario) => context.Usuarios.Update(usuario);
}
