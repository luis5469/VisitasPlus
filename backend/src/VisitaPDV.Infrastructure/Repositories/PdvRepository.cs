using Microsoft.EntityFrameworkCore;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class PdvRepository(ApplicationDbContext context)
    : BaseRepository<Pdv>(context), IPdvRepository
{
    public async Task<IEnumerable<Pdv>> GetActivosAsync(CancellationToken ct = default)
        => await DbSet.AsNoTracking()
                      .Where(p => p.Activo)
                      .OrderBy(p => p.Nombre)
                      .ToListAsync(ct);

    public async Task<IEnumerable<Pdv>> GetAsignadosAsync(string visitadorId, CancellationToken ct = default)
        => await context.AgendaVisitas
                        .AsNoTracking()
                        .Where(a => a.VisitadorId == visitadorId && a.Pdv.Activo)
                        .Select(a => a.Pdv)
                        .Distinct()
                        .OrderBy(p => p.Nombre)
                        .ToListAsync(ct);

    public async Task<Pdv?> GetByCodigo(string codigo, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
                      .FirstOrDefaultAsync(p => p.Codigo == codigo, ct);
}
