using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public class BaseRepository<T>(ApplicationDbContext context) : IRepository<T>
    where T : BaseEntity
{
    protected readonly DbSet<T> DbSet = context.Set<T>();

    public async Task<T?> GetByIdAsync(string id, CancellationToken ct = default)
        => await DbSet.FindAsync([id], ct);

    public async Task<IEnumerable<T>> GetAllAsync(CancellationToken ct = default)
        => await DbSet.AsNoTracking().ToListAsync(ct);

    public async Task<IEnumerable<T>> FindAsync(
        Expression<Func<T, bool>> predicate, CancellationToken ct = default)
        => await DbSet.AsNoTracking().Where(predicate).ToListAsync(ct);

    public async Task AddAsync(T entity, CancellationToken ct = default)
        => await DbSet.AddAsync(entity, ct);

    public void Update(T entity) => DbSet.Update(entity);

    public void Remove(T entity) => DbSet.Remove(entity);
}
