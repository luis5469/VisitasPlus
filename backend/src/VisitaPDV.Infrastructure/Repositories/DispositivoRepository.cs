using Microsoft.EntityFrameworkCore;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class DispositivoRepository(ApplicationDbContext context)
    : IDispositivoRepository
{
    public Task<Dispositivo?> GetByDeviceIdAsync(string deviceId, CancellationToken ct = default) =>
        context.Set<Dispositivo>()
            .FirstOrDefaultAsync(d => d.DeviceId == deviceId, ct);

    public async Task AddAsync(Dispositivo dispositivo, CancellationToken ct = default) =>
        await context.Set<Dispositivo>().AddAsync(dispositivo, ct);

    public void Update(Dispositivo dispositivo) => context.Set<Dispositivo>().Update(dispositivo);

    public async Task<IEnumerable<string>> GetTokensByUsuarioAsync(string usuarioId, CancellationToken ct = default) =>
        await context.Set<Dispositivo>()
            .Where(d => d.UsuarioId == usuarioId && d.PushToken != null && d.Activo)
            .Select(d => d.PushToken!)
            .ToListAsync(ct);
}
