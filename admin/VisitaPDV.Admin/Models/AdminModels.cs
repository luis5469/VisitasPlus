namespace VisitaPDV.Admin.Models;

// ── Dashboard ────────────────────────────────────────────────────────────────
public record DashboardKpiModel(
    int NovedadesAbiertas,
    int NovedadesVencidas,
    double TiempoResolucionPromedioHoras,
    int VisitasEjecutadas,
    double PorcentajeCumplimientoAgenda,
    int TotalAgendado,
    int TotalNovedades,
    DateTime GeneradoEn
);

public record IncidenciaCategoriaModel(
    string Categoria, int Total, int Abiertas, int Resueltas, int Vencidas);

public record VisitadorEficienciaModel(
    string VisitadorId, string NombreCompleto,
    int VisitasCompletadas, int VisitasAgendadas,
    double PorcentajeCumplimiento,
    int NovedadesRegistradas, int NovedadesResueltas,
    double TiempoPromedioVisitaMinutos
);

public record AlertaDashboardModel(
    string NovedadId, string Titulo, string Categoria, string Prioridad,
    DateTime FechaSeguimiento, int DiasVencida, string NombrePdv, string ResponsableNombre
);

public record NovedadesTimelineModel(
    DateTime Fecha, int Abiertas, int EnProgreso, int Resueltas, int Cerradas);

public record DashboardResumenModel(
    DateTime Desde, DateTime Hasta,
    DashboardKpiModel Kpis,
    IEnumerable<IncidenciaCategoriaModel> IncidenciasPorCategoria,
    IEnumerable<VisitadorEficienciaModel> EficienciaPorVisitador,
    IEnumerable<object> Heatmap,
    IEnumerable<AlertaDashboardModel> AlertasActivas,
    IEnumerable<NovedadesTimelineModel> Timeline
);

// ── Usuarios ─────────────────────────────────────────────────────────────────
public record UsuarioModel(
    string Id, string Nombre, string Apellido, string Email,
    string Username, string Rol, bool Activo,
    int IntentosFallidos, DateTime? UltimoLogin, string? ZonaId)
{
    public bool BiometriaHabilitada { get; init; }

    public DateTime CreatedAt { get; init; }
}

public record CreateUsuarioModel(
    string Nombre,
    string Apellido,
    string Email,
    string Username,
    string Password,
    string Rol,
    string? ZonaId);

public record UpdateUsuarioModel(
    string Nombre,
    string Apellido,
    string Email,
    string Username,
    string Rol,
    string? ZonaId);

public record CambiarPasswordModel(
    string Password);

// ── Farmacias / Asignaciones ────────────────────────────────────────────────
public record FarmaciaModel(
    string Id,
    string Codigo,
    string Nombre,
    string Direccion,
    string Ciudad,
    string? Zona,
    string? Responsable,
    string? Telefono,
    decimal Latitud,
    decimal Longitud,
    int GeofenceMetros,
    bool Activo,
    DateTime CreatedAt);

public record UpsertFarmaciaModel(
    string Codigo,
    string Nombre,
    string Direccion,
    string Ciudad,
    string? Zona,
    string? Responsable,
    string? Telefono,
    decimal Latitud,
    decimal Longitud,
    int GeofenceMetros);

public record AsignacionFarmaciaModel(
    string Id,
    string FarmaciaId,
    string CodigoFarmacia,
    string NombreFarmacia,
    string UsuarioId,
    string NombreUsuario,
    DateTime FechaPlaneada,
    string? Observaciones,
    bool Completada,
    DateTime CreatedAt);

public record CreateAsignacionModel(
    string FarmaciaId,
    string UsuarioId,
    DateTime FechaPlaneada,
    string? Observaciones);

// ── Roles & Permisos ──────────────────────────────────────────────────────────
public record RolModel(string Id, string Nombre, string Descripcion, bool Activo, DateTime CreatedAt);
public record PermisoModel(string Id, string Nombre, string Modulo, string Accion, string Descripcion);

// ── Auditoría ─────────────────────────────────────────────────────────────────
public record AuditoriaModel(
    string Id, string Accion, string Modulo,
    string? EntidadAfectada,
    string? IpAddress, bool Exitoso, string? MensajeError,
    DateTime CreatedAt)
{
    public string? UsuarioId { get; init; }

    public string? EntidadId { get; init; }
}

// ── Paginación genérica ────────────────────────────────────────────────────────
public record PagedResult<T>(
    IEnumerable<T> Items, int TotalCount, int Page, int PageSize)
{
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
}

public record ApiRequestResult<T>(T? Data, string? ErrorMessage)
{
    public bool Success => string.IsNullOrWhiteSpace(ErrorMessage);

    public static ApiRequestResult<T> Ok(T data) => new(data, null);

    public static ApiRequestResult<T> Fail(string message) => new(default, message);
}

// ── Auth ────────────────────────────────────────────────────────────────────
public record LoginRequest(string UsernameOrEmail, string Password, string? DeviceId);
public record LoginResponse(string AccessToken, string RefreshToken, DateTime ExpiresAt,
    string UserId, string Username, string NombreCompleto, string Rol);
public record LoginAttemptResult(bool Success, LoginResponse? Session, string? ErrorMessage)
{
    public static LoginAttemptResult Ok(LoginResponse session) => new(true, session, null);

    public static LoginAttemptResult Fail(string message) => new(false, null, message);
}
public record ApiResponse<T>(bool Success, string Message, T? Data, IEnumerable<string> Errors);

// ── Novedades ───────────────────────────────────────────────────────────────
public record NovedadListModel(
    string Id,
    string PdvId,
    string Titulo,
    string Categoria,
    string Prioridad,
    string Estado,
    DateTime FechaSeguimiento,
    int TotalImagenes,
    DateTime CreadoEn
);

public record NovedadModel(
    string Id,
    string VisitaId,
    string PdvId,
    string Titulo,
    string Descripcion,
    string Categoria,
    string Prioridad,
    string Estado,
    string ResponsableSolucionId,
    string ResponsableSeguimientoId,
    DateTime FechaSeguimiento,
    bool Sincronizado,
    DateTime CreadoEn,
    List<NovedadImagenModel> Imagenes,
    List<NovedadHistorialModel> Historial
);

public record NovedadImagenModel(
    string Id,
    string UrlImagen,
    string NombreArchivo,
    long TamanoBytes,
    bool MarcaAguaAplicada,
    decimal? Latitud,
    decimal? Longitud,
    DateTime? TimestampCaptura
);

public record NovedadHistorialModel(
    string Id,
    string EstadoAnterior,
    string EstadoNuevo,
    string Comentario,
    string UsuarioId,
    DateTime CreadoEn
);

public record NovedadesPagedResponse(
    List<NovedadListModel> Items,
    int TotalItems,
    int Pagina,
    int Tamano,
    int TotalPaginas
);

public record ActualizarNovedadModel(
    string Titulo,
    string Descripcion,
    string Categoria,
    string Prioridad,
    string ResponsableSolucionId,
    string ResponsableSeguimientoId,
    DateTime FechaSeguimiento
);

public record NovedadAnalisisResult(
    string Categoria,
    string Prioridad,
    string TituloSugerido,
    string Justificacion
);
