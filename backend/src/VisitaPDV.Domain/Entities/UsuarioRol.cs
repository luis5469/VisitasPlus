namespace VisitaPDV.Domain.Entities;

/// <summary>Tabla de unión entre Usuario y Rol (soporte multi-rol futuro).</summary>
public class UsuarioRol
{
    public string UsuarioId { get; private set; } = string.Empty;
    public string RolId { get; private set; } = string.Empty;

    public Usuario Usuario { get; private set; } = null!;
    public Rol Rol { get; private set; } = null!;

    protected UsuarioRol() { }

    public static UsuarioRol Create(string usuarioId, string rolId) =>
        new() { UsuarioId = usuarioId, RolId = rolId };
}
