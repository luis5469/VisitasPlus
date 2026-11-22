using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

/// <summary>Visita programada / agenda</summary>
public class AgendaVisita : AuditableEntity
{
    public string   PdvId        { get; private set; } = string.Empty;
    public string   VisitadorId  { get; private set; } = string.Empty;
    public DateTime FechaPlaneada { get; private set; }
    public string?  Observaciones { get; private set; }
    public bool   Completada   { get; private set; }

    // Navigation
    public Pdv     Pdv       { get; private set; } = null!;
    public Usuario Visitador  { get; private set; } = null!;

    protected AgendaVisita() { }

    public static AgendaVisita Create(string pdvId, string visitadorId, DateTime fechaPlaneada, string? observaciones = null) =>
        new()
        {
            PdvId         = pdvId,
            VisitadorId   = visitadorId,
            FechaPlaneada = fechaPlaneada,
            Observaciones = observaciones,
        };

    public void Completar() => Completada = true;
}
