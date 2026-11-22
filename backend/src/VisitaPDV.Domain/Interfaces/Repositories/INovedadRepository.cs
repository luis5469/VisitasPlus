using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Domain.Interfaces.Repositories;

public interface INovedadRepository : IRepository<Novedad>
{
    Task<Novedad?> GetConDetallesAsync(string id, CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetByVisitaAsync(string visitaId, CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetByPdvAsync(string pdvId, CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetByResponsableAsync(string usuarioId, CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetVencidasAsync(CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetByEstadoAsync(NovedadStatus estado, CancellationToken ct = default);
    Task<IEnumerable<Novedad>> GetByFiltroAsync(
        NovedadStatus? estado, string? categoria, string? prioridad,
        string? pdvId, string? responsableId, DateTime? desde, DateTime? hasta,
        int pagina, int tamano, CancellationToken ct = default);
}
