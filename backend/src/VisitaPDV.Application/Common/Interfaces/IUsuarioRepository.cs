using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IUsuarioRepository
{
    Task<Usuario?> GetByIdAsync(string id, CancellationToken ct = default);
    Task<Usuario?> GetByUsernameOrEmailAsync(string usernameOrEmail, CancellationToken ct = default);
    Task AddAsync(Usuario usuario, CancellationToken ct = default);
    void Update(Usuario usuario);
}
