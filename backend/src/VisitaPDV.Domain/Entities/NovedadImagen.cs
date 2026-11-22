using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

public class NovedadImagen : BaseEntity
{
    public string NovedadId { get; private set; } = string.Empty;
    public string UrlImagen { get; private set; } = string.Empty;
    public string NombreArchivo { get; private set; } = string.Empty;
    public long TamanoBytes { get; private set; }
    public bool MarcaAguaAplicada { get; private set; }
    public decimal? Latitud { get; private set; }
    public decimal? Longitud { get; private set; }
    public DateTime? TimestampCaptura { get; private set; }
    public string SubidoPor { get; private set; } = string.Empty;

    protected NovedadImagen() { }

    public static NovedadImagen Create(
        string novedadId, string url, string nombre,
        long tamano, string subidoPor,
        decimal? lat = null, decimal? lng = null) =>
        new()
        {
            NovedadId = novedadId,
            UrlImagen = url,
            NombreArchivo = nombre,
            TamanoBytes = tamano,
            SubidoPor = subidoPor,
            Latitud = lat,
            Longitud = lng,
            TimestampCaptura = DateTime.UtcNow,
            MarcaAguaAplicada = true
        };
}
