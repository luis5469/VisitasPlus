using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IDispositivoRepository
{
    Task<Dispositivo?> GetByDeviceIdAsync(string deviceId, CancellationToken ct = default);
    Task AddAsync(Dispositivo dispositivo, CancellationToken ct = default);
    void Update(Dispositivo dispositivo);
    Task<IEnumerable<string>> GetTokensByUsuarioAsync(string usuarioId, CancellationToken ct = default);
}
