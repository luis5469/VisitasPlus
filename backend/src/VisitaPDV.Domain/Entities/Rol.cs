using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

public class Rol : BaseEntity
{
    public string Nombre { get; private set; } = string.Empty;
    public string Descripcion { get; private set; } = string.Empty;
    public bool Activo { get; private set; } = true;

    public ICollection<RolPermiso> RolPermisos { get; private set; } = [];
    public ICollection<UsuarioRol> UsuarioRoles { get; private set; } = [];

    protected Rol() { }

    public static Rol Create(string nombre, string descripcion) =>
        new() { Nombre = nombre, Descripcion = descripcion };

    public void Desactivar() => Activo = false;
    public void Activar() => Activo = true;
}
