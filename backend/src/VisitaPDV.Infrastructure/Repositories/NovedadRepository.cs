using Microsoft.EntityFrameworkCore;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class NovedadRepository(ApplicationDbContext context)
    : BaseRepository<Novedad>(context), INovedadRepository
{
    public async Task<Novedad?> GetConDetallesAsync(string id, CancellationToken ct = default)
        => await DbSet
            .Include(n => n.Imagenes)
            .Include(n => n.Historial)
            .FirstOrDefaultAsync(n => n.Id == id, ct);

    public async Task<IEnumerable<Novedad>> GetByVisitaAsync(string visitaId, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
            .Include(n => n.Imagenes)
            .Where(n => n.VisitaId == visitaId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(ct);

    public async Task<IEnumerable<Novedad>> GetByPdvAsync(string pdvId, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
            .Include(n => n.Imagenes)
            .Where(n => n.PdvId == pdvId)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(ct);

    public async Task<IEnumerable<Novedad>> GetByResponsableAsync(string usuarioId, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
            .Include(n => n.Imagenes)
            .Where(n => n.ResponsableSolucionId == usuarioId || n.ResponsableSeguimientoId == usuarioId)
            .OrderByDescending(n => n.FechaSeguimiento)
            .ToListAsync(ct);

    public async Task<IEnumerable<Novedad>> GetVencidasAsync(CancellationToken ct = default)
        => await DbSet.AsNoTracking()
            .Where(n => n.FechaSeguimiento < DateTime.UtcNow
                        && n.Estado != NovedadStatus.Resuelta
                        && n.Estado != NovedadStatus.Cerrada)
            .OrderBy(n => n.FechaSeguimiento)
            .ToListAsync(ct);

    public async Task<IEnumerable<Novedad>> GetByEstadoAsync(NovedadStatus estado, CancellationToken ct = default)
        => await DbSet.AsNoTracking()
            .Where(n => n.Estado == estado)
            .OrderByDescending(n => n.CreatedAt)
            .ToListAsync(ct);

    public async Task<IEnumerable<Novedad>> GetByFiltroAsync(
        NovedadStatus? estado, string? categoria, string? prioridad,
        string? pdvId, string? responsableId,
        DateTime? desde, DateTime? hasta,
        int pagina, int tamano, CancellationToken ct = default)
    {
        var query = DbSet.AsNoTracking().Include(n => n.Imagenes).AsQueryable();

        if (estado.HasValue)      query = query.Where(n => n.Estado == estado.Value);
        if (!string.IsNullOrWhiteSpace(categoria)) query = query.Where(n => n.Categoria == categoria);
        if (!string.IsNullOrWhiteSpace(prioridad)) query = query.Where(n => n.Prioridad == prioridad);
        if (!string.IsNullOrEmpty(pdvId))       query = query.Where(n => n.PdvId == pdvId);
        if (!string.IsNullOrEmpty(responsableId))
            query = query.Where(n =>
                n.ResponsableSolucionId == responsableId ||
                n.ResponsableSeguimientoId == responsableId);
        if (desde.HasValue)  query = query.Where(n => n.CreatedAt >= desde.Value);
        if (hasta.HasValue)  query = query.Where(n => n.CreatedAt <= hasta.Value);

        return await query
            .OrderByDescending(n => n.CreatedAt)
            .Skip((pagina - 1) * tamano)
            .Take(tamano)
            .ToListAsync(ct);
    }
}
