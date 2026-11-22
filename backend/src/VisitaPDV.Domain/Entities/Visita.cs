using VisitaPDV.Domain.Common;
using VisitaPDV.Domain.Enums;

namespace VisitaPDV.Domain.Entities;

public class Visita : AuditableEntity
{
    public string PdvId { get; private set; } = string.Empty;
    public string VisitadorId { get; private set; } = string.Empty;
    public VisitStatus Estado { get; private set; } = VisitStatus.EnCurso;
    public decimal? LatitudInicio { get; private set; }
    public decimal? LongitudInicio { get; private set; }
    public decimal? LatitudFin { get; private set; }
    public decimal? LongitudFin { get; private set; }
    public DateTime TimestampInicio { get; private set; } = DateTime.UtcNow;
    public DateTime? TimestampFin { get; private set; }
    public string? ActaPdfUrl { get; private set; }
    public bool Sincronizado { get; private set; } = true;

    // Navigation
    public Pdv     Pdv       { get; private set; } = null!;
    public Usuario Visitador  { get; private set; } = null!;
    public ICollection<Novedad> Novedades { get; private set; } = [];

    protected Visita() { }

    public static Visita Create(string pdvId, string visitadorId, decimal lat, decimal lng) =>
        new()
        {
            PdvId = pdvId,
            VisitadorId = visitadorId,
            LatitudInicio = lat,
            LongitudInicio = lng
        };

    public void Finalizar(decimal lat, decimal lng)
    {
        Estado = VisitStatus.Completada;
        TimestampFin = DateTime.UtcNow;
        LatitudFin = lat;
        LongitudFin = lng;
    }

    public void SetActaPdf(string url) => ActaPdfUrl = url;
}
