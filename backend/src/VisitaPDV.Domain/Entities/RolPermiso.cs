namespace VisitaPDV.Domain.Entities;

/// <summary>Tabla de unión entre Rol y Permiso.</summary>
public class RolPermiso
{
    public string RolId { get; private set; } = string.Empty;
    public string PermisoId { get; private set; } = string.Empty;

    public Rol Rol { get; private set; } = null!;
    public Permiso Permiso { get; private set; } = null!;

    protected RolPermiso() { }

    public static RolPermiso Create(string rolId, string permisoId) =>
        new() { RolId = rolId, PermisoId = permisoId };
}
