using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

public class Permiso : BaseEntity
{
    public string Nombre { get; private set; } = string.Empty;
    public string Modulo { get; private set; } = string.Empty;
    public string Accion { get; private set; } = string.Empty;
    public string Descripcion { get; private set; } = string.Empty;

    public ICollection<RolPermiso> RolPermisos { get; private set; } = [];

    protected Permiso() { }

    public static Permiso Create(string modulo, string accion, string descripcion = "") =>
        new()
        {
            Nombre = $"{modulo}.{accion}",
            Modulo = modulo,
            Accion = accion,
            Descripcion = descripcion
        };
}
