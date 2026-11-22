using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Domain.Entities;

public class Usuario : AuditableEntity
{
    public string Nombre { get; private set; } = string.Empty;
    public string Apellido { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string Username { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public UserRole Rol { get; private set; }
    public string? ZonaId { get; private set; }
    public string? SupervisorId { get; private set; }
    public bool Activo { get; private set; } = true;
    public bool BiometriaHabilitada { get; private set; }
    public string? PushToken { get; private set; }
    public int IntentosFallidos { get; private set; }
    public DateTime? BloqueadoHasta { get; private set; }
    public DateTime? UltimoLogin { get; private set; }
    public string NombreCompleto => $"{Nombre} {Apellido}";

    // Navigation
    public ICollection<Visita> Visitas { get; private set; } = [];
    public ICollection<RefreshToken> RefreshTokens { get; private set; } = [];
    public ICollection<Dispositivo> Dispositivos { get; private set; } = [];
    public ICollection<UsuarioRol> UsuarioRoles { get; private set; } = [];

    protected Usuario() { }

    public static Usuario Create(
        string nombre, string apellido,
        string email, string username,
        string passwordHash, UserRole rol,
        string? zonaId = null) =>
        new()
        {
            Nombre = nombre,
            Apellido = apellido,
            Email = email.ToLowerInvariant(),
            Username = username.ToLowerInvariant(),
            PasswordHash = passwordHash,
            Rol = rol,
            ZonaId = string.IsNullOrWhiteSpace(zonaId) ? null : zonaId
        };

    public void Actualizar(
        string nombre, string apellido,
        string email, string username,
        UserRole rol, string? zonaId)
    {
        Nombre = nombre;
        Apellido = apellido;
        Email = email.ToLowerInvariant();
        Username = username.ToLowerInvariant();
        Rol = rol;
        ZonaId = string.IsNullOrWhiteSpace(zonaId) ? null : zonaId;
    }

    public void ActualizarPassword(string passwordHash)
    {
        PasswordHash = passwordHash;
    }

    public void RegisterFailedAttempt()
    {
        IntentosFallidos++;
        if (IntentosFallidos >= 5)
            BloqueadoHasta = DateTime.UtcNow.AddMinutes(30);
    }

    public void ResetLoginAttempts()
    {
        IntentosFallidos = 0;
        BloqueadoHasta = null;
    }

    public void RecordLogin()
    {
        UltimoLogin = DateTime.UtcNow;
        ResetLoginAttempts();
    }

    public bool IsBlocked() =>
        BloqueadoHasta.HasValue && BloqueadoHasta > DateTime.UtcNow;

    public void Activar()   => Activo = true;
    public void Desactivar() => Activo = false;

    public void SetPushToken(string token) => PushToken = token;

    public void EnableBiometrics() => BiometriaHabilitada = true;
}
