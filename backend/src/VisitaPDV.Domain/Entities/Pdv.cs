using VisitaPDV.Domain.Common;

namespace VisitaPDV.Domain.Entities;

/// <summary>Punto de Venta</summary>
public class Pdv : AuditableEntity
{
    public string Codigo        { get; private set; } = string.Empty;
    public string Nombre        { get; private set; } = string.Empty;
    public string Direccion     { get; private set; } = string.Empty;
    public string Ciudad        { get; private set; } = string.Empty;
    public string? Zona         { get; private set; }
    public string? Responsable  { get; private set; }
    public string? Telefono     { get; private set; }
    public decimal Latitud      { get; private set; }
    public decimal Longitud     { get; private set; }
    /// <summary>Radio del geofence en metros</summary>
    public int GeofenceMetros   { get; private set; } = 100;
    public bool Activo          { get; private set; } = true;

    // Navigation
    public ICollection<Visita>       Visitas       { get; private set; } = [];
    public ICollection<AgendaVisita> AgendaVisitas { get; private set; } = [];

    protected Pdv() { }

    public static Pdv Create(
        string codigo, string nombre, string direccion,
        string ciudad, decimal latitud, decimal longitud,
        string? zona = null, string? responsable = null,
        string? telefono = null, int geofenceMetros = 100) =>
        new()
        {
            Codigo        = codigo,
            Nombre        = nombre,
            Direccion     = direccion,
            Ciudad        = ciudad,
            Latitud       = latitud,
            Longitud      = longitud,
            Zona          = zona,
            Responsable   = responsable,
            Telefono      = telefono,
            GeofenceMetros = geofenceMetros,
        };

    public void Desactivar() => Activo = false;
    public void Activar()    => Activo = true;

    public void Actualizar(
        string codigo,
        string nombre,
        string direccion,
        string ciudad,
        decimal latitud,
        decimal longitud,
        string? zona = null,
        string? responsable = null,
        string? telefono = null,
        int geofenceMetros = 100)
    {
        Codigo = codigo;
        Nombre = nombre;
        Direccion = direccion;
        Ciudad = ciudad;
        Latitud = latitud;
        Longitud = longitud;
        Zona = zona;
        Responsable = responsable;
        Telefono = telefono;
        ActualizarGeofence(geofenceMetros);
    }

    public void ActualizarGeofence(int metros)
    {
        if (metros < 10)  throw new ArgumentException("Geofence mínimo: 10 metros.");
        if (metros > 5000) throw new ArgumentException("Geofence máximo: 5000 metros.");
        GeofenceMetros = metros;
    }

    /// <summary>
    /// Calcula si las coordenadas dadas están dentro del geofence usando
    /// la fórmula de Haversine.
    /// </summary>
    public bool EstaDentroDeGeofence(decimal latGps, decimal lngGps)
    {
        const double R = 6371000; // radio Tierra en metros
        var lat1 = (double)Latitud  * Math.PI / 180;
        var lat2 = (double)latGps   * Math.PI / 180;
        var dLat = (double)(latGps - Latitud)   * Math.PI / 180;
        var dLng = (double)(lngGps - Longitud)  * Math.PI / 180;

        var a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2)
              + Math.Cos(lat1) * Math.Cos(lat2)
              * Math.Sin(dLng / 2) * Math.Sin(dLng / 2);
        var distancia = R * 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));
        return distancia <= GeofenceMetros;
    }
}
