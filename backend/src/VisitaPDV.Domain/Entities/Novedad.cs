using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Exceptions;

namespace VisitaPDV.Domain.Entities;

public class Novedad : AuditableEntity
{
    public string VisitaId { get; private set; } = string.Empty;
    public string PdvId { get; private set; } = string.Empty;
    public string Titulo { get; private set; } = string.Empty;
    public string Descripcion { get; private set; } = string.Empty;
    public string Categoria { get; private set; } = string.Empty;
    public string Prioridad { get; private set; } = string.Empty;
    public NovedadStatus Estado { get; private set; } = NovedadStatus.Abierta;
    public string ResponsableSolucionId { get; private set; } = string.Empty;
    public string ResponsableSeguimientoId { get; private set; } = string.Empty;
    public DateTime FechaSeguimiento { get; private set; }
    public bool Sincronizado { get; private set; } = true;

    // Navigation
    public Visita Visita { get; private set; } = null!;
    public ICollection<NovedadImagen> Imagenes { get; private set; } = new List<NovedadImagen>();
    public ICollection<NovedadHistorial> Historial { get; private set; } = new List<NovedadHistorial>();

    protected Novedad() { }

    public static Novedad Create(
        string visitaId, string pdvId, string titulo, string descripcion,
        string categoria, string prioridad,
        string responsableSolucion, string responsableSeguimiento,
        DateTime fechaSeguimiento) =>
        new()
        {
            VisitaId = visitaId,
            PdvId = pdvId,
            Titulo = titulo,
            Descripcion = descripcion,
            Categoria = categoria,
            Prioridad = prioridad,
            ResponsableSolucionId = responsableSolucion,
            ResponsableSeguimientoId = responsableSeguimiento,
            FechaSeguimiento = fechaSeguimiento
        };

    public void CambiarEstado(NovedadStatus nuevoEstado, string usuarioId, string comentario)
    {
        if (Estado == NovedadStatus.Cerrada)
            throw new DomainException("Una novedad cerrada no puede cambiar de estado.");

        var anterior = Estado;
        Estado = nuevoEstado;
        Historial.Add(NovedadHistorial.Create(Id, anterior, nuevoEstado, usuarioId, comentario));
    }

    public void Actualizar(
        string? titulo, string? descripcion, string? categoria, string? prioridad,
        string? responsableSolucion, string? responsableSeguimiento, DateTime? fechaSeguimiento)
    {
        if (titulo is not null) Titulo = titulo;
        if (descripcion is not null) Descripcion = descripcion;
        if (categoria is not null) Categoria = categoria;
        if (prioridad is not null) Prioridad = prioridad;
        if (responsableSolucion is not null) ResponsableSolucionId = responsableSolucion;
        if (responsableSeguimiento is not null) ResponsableSeguimientoId = responsableSeguimiento;
        if (fechaSeguimiento.HasValue) FechaSeguimiento = fechaSeguimiento.Value;
    }

    public void AgregarImagen(NovedadImagen imagen)
    {
        ((List<NovedadImagen>)Imagenes).Add(imagen);
    }

    public void RemoverImagen(string imagenId)
    {
        var imagen = Imagenes.FirstOrDefault(i => i.Id == imagenId);
        if (imagen is not null)
            ((List<NovedadImagen>)Imagenes).Remove(imagen);
    }
}
