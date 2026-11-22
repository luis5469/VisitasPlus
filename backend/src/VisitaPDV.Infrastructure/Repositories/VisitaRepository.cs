using Microsoft.EntityFrameworkCore;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class VisitaRepository(ApplicationDbContext context)
    : BaseRepository<Visita>(context), IVisitaRepository
{
    public async Task<Visita?> GetVisitaActivaAsync(string visitadorId, CancellationToken ct = default)
        => await DbSet.FirstOrDefaultAsync(
            v => v.VisitadorId == visitadorId && v.Estado == VisitStatus.EnCurso, ct);

    public async Task<IEnumerable<Visita>> GetByVisitadorAsync(string visitadorId, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
                      .Include(v => v.Pdv)
                      .Where(v => v.VisitadorId == visitadorId)
                      .OrderByDescending(v => v.TimestampInicio)
                      .ToListAsync(ct);

    public async Task<IEnumerable<Visita>> GetByPdvAsync(string pdvId, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
                      .Include(v => v.Visitador)
                      .Where(v => v.PdvId == pdvId)
                      .OrderByDescending(v => v.TimestampInicio)
                      .ToListAsync(ct);

    public async Task<Visita?> GetConDetallesAsync(string id, CancellationToken ct = default)
        => await DbSet.Include(v => v.Pdv)
                      .Include(v => v.Visitador)
                      .FirstOrDefaultAsync(v => v.Id == id, ct);
}
