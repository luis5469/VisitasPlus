using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

public class Auditoria : BaseEntity
{
    public string? UsuarioId { get; private set; }
    public string Accion { get; private set; } = string.Empty;
    public string Modulo { get; private set; } = string.Empty;
    public string? EntidadAfectada { get; private set; }
    public string? EntidadId { get; private set; }
    public string? DetalleAnterior { get; private set; }   // JSON
    public string? DetalleNuevo { get; private set; }      // JSON
    public string? IpAddress { get; private set; }
    public string? UserAgent { get; private set; }
    public bool Exitoso { get; private set; }
    public string? MensajeError { get; private set; }

    public Usuario? Usuario { get; private set; }

    protected Auditoria() { }

    public static Auditoria Create(
        string modulo,
        string accion,
        bool exitoso,
        string? usuarioId = null,
        string? entidadAfectada = null,
        string? entidadId = null,
        string? detalleAnterior = null,
        string? detalleNuevo = null,
        string? ipAddress = null,
        string? userAgent = null,
        string? mensajeError = null) =>
        new()
        {
            UsuarioId = usuarioId,
            Modulo = modulo,
            Accion = accion,
            Exitoso = exitoso,
            EntidadAfectada = entidadAfectada,
            EntidadId = entidadId,
            DetalleAnterior = detalleAnterior,
            DetalleNuevo = detalleNuevo,
            IpAddress = ipAddress,
            UserAgent = userAgent,
            MensajeError = mensajeError
        };
}
