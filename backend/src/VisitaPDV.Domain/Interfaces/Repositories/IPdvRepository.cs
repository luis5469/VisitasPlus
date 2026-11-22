using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Domain.Interfaces.Repositories;

public interface IPdvRepository : IRepository<Pdv>
{
    Task<IEnumerable<Pdv>> GetActivosAsync(CancellationToken ct = default);
    Task<IEnumerable<Pdv>> GetAsignadosAsync(string visitadorId, CancellationToken ct = default);
    Task<Pdv?> GetByCodigo(string codigo, CancellationToken ct = default);
}
