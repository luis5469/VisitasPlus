using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

public class Dispositivo : BaseEntity
{
    public string UsuarioId { get; private set; } = string.Empty;
    public string DeviceId { get; private set; } = string.Empty;
    public string Nombre { get; private set; } = string.Empty;
    public string Plataforma { get; private set; } = string.Empty;   // Android | iOS
    public string? ModeloDispositivo { get; private set; }
    public string? VersionSO { get; private set; }
    public string? PushToken { get; private set; }
    public bool Activo { get; private set; } = true;
    public bool Confiable { get; private set; }
    public DateTime? UltimoAcceso { get; private set; }

    public Usuario Usuario { get; private set; } = null!;
    public ICollection<RefreshToken> RefreshTokens { get; private set; } = [];

    protected Dispositivo() { }

    public static Dispositivo Create(
        string usuarioId,
        string deviceId,
        string nombre,
        string plataforma,
        string? modeloDispositivo = null,
        string? versionSO = null) =>
        new()
        {
            UsuarioId = usuarioId,
            DeviceId = deviceId,
            Nombre = nombre,
            Plataforma = plataforma,
            ModeloDispositivo = modeloDispositivo,
            VersionSO = versionSO
        };

    public void RegistrarAcceso()
    {
        UltimoAcceso = DateTime.UtcNow;
        Activo = true;
    }

    public void MarcarConfiable() => Confiable = true;
    public void ActualizarPushToken(string token) => PushToken = token;
    public void Desactivar() => Activo = false;
}
