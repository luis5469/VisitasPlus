using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Identity;

public sealed class PasswordHasher : IPasswordHasher
{
    // WorkFactor 12 = equilibrio seguridad/rendimiento (~300ms en hardware moderno)
    private const int WorkFactor = 12;

    public string Hash(string password) =>
        BCrypt.Net.BCrypt.HashPassword(password, WorkFactor);

    public bool Verify(string password, string hash) =>
        BCrypt.Net.BCrypt.Verify(password, hash);
}
