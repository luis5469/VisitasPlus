using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Domain.Interfaces.Repositories;

public interface IVisitaRepository : IRepository<Visita>
{
    Task<Visita?> GetVisitaActivaAsync(string visitadorId, CancellationToken ct = default);
    Task<IEnumerable<Visita>> GetByVisitadorAsync(string visitadorId, CancellationToken ct = default);
    Task<IEnumerable<Visita>> GetByPdvAsync(string pdvId, CancellationToken ct = default);
    Task<Visita?> GetConDetallesAsync(string id, CancellationToken ct = default);
}
