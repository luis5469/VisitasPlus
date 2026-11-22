using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.API.Controllers;

/// <summary>
/// Endpoints de administración del sistema: usuarios, roles, permisos y auditoría.
/// Requiere rol Administrador.
/// </summary>
[Authorize(Roles = "Administrador")]
public sealed class AdminController : BaseApiController
{
    private readonly ApplicationDbContext _db;

    public AdminController(ApplicationDbContext db) => _db = db;

    // ── Usuarios ──────────────────────────────────────────────────────────────

    /// <summary>Lista todos los usuarios del sistema.</summary>
    [HttpGet("usuarios")]
    public async Task<IActionResult> GetUsuarios(CancellationToken ct)
    {
        var usuarios = await _db.Usuarios
            .AsNoTracking()
            .OrderBy(u => u.Apellido).ThenBy(u => u.Nombre)
            .Select(u => new UsuarioDto(
                u.Id,
                u.Nombre,
                u.Apellido,
                u.Email,
                u.Username,
                u.Rol.ToString(),
                u.Activo,
                u.IntentosFallidos,
                u.UltimoLogin,
                u.ZonaId))
            .ToListAsync(ct);

        return Ok(ApiResponse<IEnumerable<UsuarioDto>>.Ok(usuarios));
    }

    /// <summary>Activa o desactiva un usuario.</summary>
    [HttpPatch("usuarios/{id}/activo")]
    public async Task<IActionResult> ToggleActivo(string id, [FromBody] ToggleActivoRequest body, CancellationToken ct)
    {
        var usuario = await _db.Usuarios.FindAsync([id], ct);
        if (usuario is null) return NotFound(ApiResponse.Fail("Usuario no encontrado."));

        if (body.Activo) usuario.Activar(); else usuario.Desactivar();
        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse.Ok());
    }

    /// <summary>Resetea los intentos fallidos y desbloquea al usuario.</summary>
    [HttpPost("usuarios/{id}/reset-intentos")]
    public async Task<IActionResult> ResetIntentos(string id, CancellationToken ct)
    {
        var usuario = await _db.Usuarios.FindAsync([id], ct);
        if (usuario is null) return NotFound(ApiResponse.Fail("Usuario no encontrado."));

        usuario.ResetLoginAttempts();
        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse.Ok());
    }

    /// <summary>Crea un nuevo usuario en el sistema.</summary>
    [HttpPost("usuarios")]
    public async Task<IActionResult> CreateUsuario([FromBody] CreateUsuarioRequest body, [FromServices] IPasswordHasher hasher, CancellationToken ct)
    {
        var usernameLower = body.Username.Trim().ToLowerInvariant();
        var emailLower = body.Email.Trim().ToLowerInvariant();

        if (await _db.Usuarios.AnyAsync(u => u.Username == usernameLower, ct))
            return BadRequest(ApiResponse.Fail("El nombre de usuario ya está registrado."));

        if (await _db.Usuarios.AnyAsync(u => u.Email == emailLower, ct))
            return BadRequest(ApiResponse.Fail("El correo electrónico ya está registrado."));

        if (string.IsNullOrWhiteSpace(body.Password) || body.Password.Length < 8)
            return BadRequest(ApiResponse.Fail("La contraseña debe tener al menos 8 caracteres."));

        if (!body.Password.Any(char.IsUpper) || !body.Password.Any(char.IsLower) || !body.Password.Any(char.IsDigit))
            return BadRequest(ApiResponse.Fail("La contraseña debe contener al menos una mayúscula, una minúscula y un número."));

        if (!Enum.TryParse<UserRole>(body.Rol, true, out var userRole))
            return BadRequest(ApiResponse.Fail("Rol no válido."));

        var passwordHash = hasher.Hash(body.Password);
        var usuario = Usuario.Create(
            body.Nombre.Trim(),
            body.Apellido.Trim(),
            emailLower,
            usernameLower,
            passwordHash,
            userRole,
            body.ZonaId?.Trim());

        usuario.CreatedBy = User.Identity?.Name ?? "admin";
        _db.Usuarios.Add(usuario);

        var rolId = body.Rol.Trim().ToUpperInvariant() switch
        {
            "ADMINISTRADOR" => "ROL-ADMINS",
            "SUPERVISOR" => "ROL-SUPERV",
            _ => "ROL-VISITD"
        };
        _db.UsuarioRoles.Add(UsuarioRol.Create(usuario.Id, rolId));

        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse.Ok());
    }

    /// <summary>Edita los datos de un usuario.</summary>
    [HttpPut("usuarios/{id}")]
    public async Task<IActionResult> UpdateUsuario(string id, [FromBody] UpdateUsuarioRequest body, CancellationToken ct)
    {
        var usuario = await _db.Usuarios.FindAsync([id], ct);
        if (usuario is null) return NotFound(ApiResponse.Fail("Usuario no encontrado."));

        var usernameLower = body.Username.Trim().ToLowerInvariant();
        var emailLower = body.Email.Trim().ToLowerInvariant();

        if (await _db.Usuarios.AnyAsync(u => u.Id != id && u.Username == usernameLower, ct))
            return BadRequest(ApiResponse.Fail("El nombre de usuario ya está en uso por otro usuario."));

        if (await _db.Usuarios.AnyAsync(u => u.Id != id && u.Email == emailLower, ct))
            return BadRequest(ApiResponse.Fail("El correo electrónico ya está en uso por otro usuario."));

        if (!Enum.TryParse<UserRole>(body.Rol, true, out var userRole))
            return BadRequest(ApiResponse.Fail("Rol no válido."));

        usuario.Actualizar(
            body.Nombre.Trim(),
            body.Apellido.Trim(),
            emailLower,
            usernameLower,
            userRole,
            body.ZonaId?.Trim());

        usuario.UpdatedBy = User.Identity?.Name ?? "admin";

        var rolId = body.Rol.Trim().ToUpperInvariant() switch
        {
            "ADMINISTRADOR" => "ROL-ADMINS",
            "SUPERVISOR" => "ROL-SUPERV",
            _ => "ROL-VISITD"
        };

        var oldRoles = await _db.UsuarioRoles.Where(ur => ur.UsuarioId == usuario.Id).ToListAsync(ct);
        _db.UsuarioRoles.RemoveRange(oldRoles);
        _db.UsuarioRoles.Add(UsuarioRol.Create(usuario.Id, rolId));

        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse.Ok());
    }

    /// <summary>Cambia la contraseña de un usuario.</summary>
    [HttpPut("usuarios/{id}/password")]
    public async Task<IActionResult> CambiarPassword(string id, [FromBody] CambiarPasswordRequest body, [FromServices] IPasswordHasher hasher, CancellationToken ct)
    {
        var usuario = await _db.Usuarios.FindAsync([id], ct);
        if (usuario is null) return NotFound(ApiResponse.Fail("Usuario no encontrado."));

        if (string.IsNullOrWhiteSpace(body.Password) || body.Password.Length < 8)
            return BadRequest(ApiResponse.Fail("La contraseña debe tener al menos 8 caracteres."));

        if (!body.Password.Any(char.IsUpper) || !body.Password.Any(char.IsLower) || !body.Password.Any(char.IsDigit))
            return BadRequest(ApiResponse.Fail("La contraseña debe contener al menos una mayúscula, una minúscula y un número."));

        var passwordHash = hasher.Hash(body.Password);
        usuario.ActualizarPassword(passwordHash);
        usuario.UpdatedBy = User.Identity?.Name ?? "admin";

        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse.Ok());
    }

    // ── Farmacias / PDV ─────────────────────────────────────────────────────

    [HttpGet("farmacias")]
    public async Task<IActionResult> GetFarmacias(CancellationToken ct)
    {
        var farmacias = await _db.Pdvs
            .AsNoTracking()
            .OrderBy(p => p.Nombre)
            .Select(p => new FarmaciaDto(
                p.Id,
                p.Codigo,
                p.Nombre,
                p.Direccion,
                p.Ciudad,
                p.Zona,
                p.Responsable,
                p.Telefono,
                p.Latitud,
                p.Longitud,
                p.GeofenceMetros,
                p.Activo,
                p.CreatedAt))
            .ToListAsync(ct);

        return Ok(ApiResponse<IEnumerable<FarmaciaDto>>.Ok(farmacias));
    }

    [HttpPost("farmacias")]
    public async Task<IActionResult> CreateFarmacia([FromBody] UpsertFarmaciaRequest body, CancellationToken ct)
    {
        body = body.Normalize();

        if (await _db.Pdvs.AnyAsync(p => p.Codigo == body.Codigo, ct))
            return BadRequest(ApiResponse.Fail("Ya existe una farmacia con ese código."));

        var farmacia = Pdv.Create(
            body.Codigo,
            body.Nombre,
            body.Direccion,
            body.Ciudad,
            body.Latitud,
            body.Longitud,
            body.Zona,
            body.Responsable,
            body.Telefono,
            body.GeofenceMetros);

        farmacia.CreatedBy = User.Identity?.Name ?? "admin";
        _db.Pdvs.Add(farmacia);
        await _db.SaveChangesAsync(ct);

        return Ok(ApiResponse<FarmaciaDto>.Ok(new FarmaciaDto(
            farmacia.Id,
            farmacia.Codigo,
            farmacia.Nombre,
            farmacia.Direccion,
            farmacia.Ciudad,
            farmacia.Zona,
            farmacia.Responsable,
            farmacia.Telefono,
            farmacia.Latitud,
            farmacia.Longitud,
            farmacia.GeofenceMetros,
            farmacia.Activo,
            farmacia.CreatedAt)));
    }

    [HttpPut("farmacias/{id}")]
    public async Task<IActionResult> UpdateFarmacia(string id, [FromBody] UpsertFarmaciaRequest body, CancellationToken ct)
    {
        body = body.Normalize();

        var farmacia = await _db.Pdvs.FindAsync([id], ct);
        if (farmacia is null)
            return NotFound(ApiResponse.Fail("Farmacia no encontrada."));

        if (await _db.Pdvs.AnyAsync(p => p.Id != id && p.Codigo == body.Codigo, ct))
            return BadRequest(ApiResponse.Fail("Ya existe otra farmacia con ese código."));

        farmacia.Actualizar(
            body.Codigo,
            body.Nombre,
            body.Direccion,
            body.Ciudad,
            body.Latitud,
            body.Longitud,
            body.Zona,
            body.Responsable,
            body.Telefono,
            body.GeofenceMetros);

        farmacia.UpdatedBy = User.Identity?.Name ?? "admin";
        await _db.SaveChangesAsync(ct);
        return Ok(ApiResponse.Ok());
    }

    [HttpPatch("farmacias/{id}/activo")]
    public async Task<IActionResult> ToggleFarmaciaActivo(string id, [FromBody] ToggleActivoRequest body, CancellationToken ct)
    {
        var farmacia = await _db.Pdvs.FindAsync([id], ct);
        if (farmacia is null)
            return NotFound(ApiResponse.Fail("Farmacia no encontrada."));

        if (body.Activo) farmacia.Activar(); else farmacia.Desactivar();
        farmacia.UpdatedBy = User.Identity?.Name ?? "admin";
        await _db.SaveChangesAsync(ct);
        return Ok(ApiResponse.Ok());
    }

    // ── Asignaciones de farmacias ───────────────────────────────────────────

    [HttpGet("asignaciones")]
    public async Task<IActionResult> GetAsignaciones(
        [FromQuery] string? usuarioId = null,
        [FromQuery] string? farmaciaId = null,
        [FromQuery] DateTime? desde = null,
        [FromQuery] DateTime? hasta = null,
        CancellationToken ct = default)
    {
        var query = _db.AgendaVisitas
            .AsNoTracking()
            .Include(a => a.Pdv)
            .Include(a => a.Visitador)
            .AsQueryable();

        if (!string.IsNullOrEmpty(usuarioId))
            query = query.Where(a => a.VisitadorId == usuarioId);

        if (!string.IsNullOrEmpty(farmaciaId))
            query = query.Where(a => a.PdvId == farmaciaId);

        if (desde.HasValue)
        {
            var desdeDate = desde.Value.Date;
            query = query.Where(a => a.FechaPlaneada >= desdeDate);
        }

        if (hasta.HasValue)
        {
            var hastaDate = hasta.Value.Date.AddDays(1).AddTicks(-1);
            query = query.Where(a => a.FechaPlaneada <= hastaDate);
        }

        var asignaciones = await query
            .OrderBy(a => a.FechaPlaneada)
            .ThenBy(a => a.Visitador.Apellido)
            .ThenBy(a => a.Pdv.Nombre)
            .Select(a => new AsignacionFarmaciaDto(
                a.Id,
                a.PdvId,
                a.Pdv.Codigo,
                a.Pdv.Nombre,
                a.VisitadorId,
                a.Visitador.Nombre + " " + a.Visitador.Apellido,
                a.FechaPlaneada,
                a.Observaciones,
                a.Completada,
                a.CreatedAt))
            .ToListAsync(ct);

        return Ok(ApiResponse<IEnumerable<AsignacionFarmaciaDto>>.Ok(asignaciones));
    }

    [HttpPost("asignaciones")]
    public async Task<IActionResult> CreateAsignacion([FromBody] CreateAsignacionRequest body, CancellationToken ct)
    {
        var usuario = await _db.Usuarios.AsNoTracking().FirstOrDefaultAsync(u => u.Id == body.UsuarioId, ct);
        if (usuario is null)
            return NotFound(ApiResponse.Fail("Usuario no encontrado."));

        var farmacia = await _db.Pdvs.AsNoTracking().FirstOrDefaultAsync(p => p.Id == body.FarmaciaId, ct);
        if (farmacia is null)
            return NotFound(ApiResponse.Fail("Farmacia no encontrada."));

        var fecha = body.FechaPlaneada.Date;
        var existe = await _db.AgendaVisitas.AnyAsync(a =>
            a.VisitadorId == body.UsuarioId &&
            a.PdvId == body.FarmaciaId &&
            a.FechaPlaneada == fecha, ct);

        if (existe)
            return BadRequest(ApiResponse.Fail("La farmacia ya está asignada a ese usuario en esa fecha."));

        var asignacion = AgendaVisita.Create(body.FarmaciaId, body.UsuarioId, fecha, body.Observaciones?.Trim());
        asignacion.CreatedBy = User.Identity?.Name ?? "admin";

        _db.AgendaVisitas.Add(asignacion);
        await _db.SaveChangesAsync(ct);
        return Ok(ApiResponse.Ok());
    }

    [HttpDelete("asignaciones/{id}")]
    public async Task<IActionResult> DeleteAsignacion(string id, CancellationToken ct)
    {
        var asignacion = await _db.AgendaVisitas.FindAsync([id], ct);
        if (asignacion is null)
            return NotFound(ApiResponse.Fail("Asignación no encontrada."));

        _db.AgendaVisitas.Remove(asignacion);
        await _db.SaveChangesAsync(ct);
        return Ok(ApiResponse.Ok());
    }

    // ── Roles ─────────────────────────────────────────────────────────────────

    /// <summary>Lista todos los roles.</summary>
    [HttpGet("roles")]
    public async Task<IActionResult> GetRoles(CancellationToken ct)
    {
        var roles = await _db.Roles
            .AsNoTracking()
            .OrderBy(r => r.Nombre)
            .Select(r => new RolDto(r.Id, r.Nombre, r.Descripcion, r.Activo, r.CreatedAt))
            .ToListAsync(ct);

        return Ok(ApiResponse<IEnumerable<RolDto>>.Ok(roles));
    }

    // ── Permisos ──────────────────────────────────────────────────────────────

    /// <summary>Lista todos los permisos del sistema.</summary>
    [HttpGet("permisos")]
    public async Task<IActionResult> GetPermisos(CancellationToken ct)
    {
        var permisos = await _db.Permisos
            .AsNoTracking()
            .OrderBy(p => p.Modulo).ThenBy(p => p.Accion)
            .Select(p => new PermisoDto(p.Id, p.Nombre, p.Modulo, p.Accion, p.Descripcion))
            .ToListAsync(ct);

        return Ok(ApiResponse<IEnumerable<PermisoDto>>.Ok(permisos));
    }

    // ── Auditoría ─────────────────────────────────────────────────────────────

    /// <summary>Registros de auditoría paginados (más recientes primero).</summary>
    [HttpGet("auditoria")]
    public async Task<IActionResult> GetAuditoria(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        CancellationToken ct = default)
    {
        if (page < 1) page = 1;
        if (pageSize < 1 || pageSize > 200) pageSize = 50;

        var query = _db.Auditorias.AsNoTracking().OrderByDescending(a => a.CreatedAt);
        var total = await query.CountAsync(ct);

        var items = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .Select(a => new AuditoriaDto(
                a.Id,
                a.Accion,
                a.Modulo,
                a.EntidadAfectada,
                a.IpAddress,
                a.Exitoso,
                a.MensajeError,
                a.CreatedAt))
            .ToListAsync(ct);

        var result = new PagedResultDto<AuditoriaDto>(items, total, page, pageSize);
        return Ok(ApiResponse<PagedResultDto<AuditoriaDto>>.Ok(result));
    }
}

// ── DTOs internos ─────────────────────────────────────────────────────────────

public sealed record UsuarioDto(
    string Id,
    string Nombre,
    string Apellido,
    string Email,
    string Username,
    string Rol,
    bool Activo,
    int IntentosFallidos,
    DateTime? UltimoLogin,
    string? ZonaId);

public sealed record ToggleActivoRequest(bool Activo);

public sealed record FarmaciaDto(
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

public sealed record UpsertFarmaciaRequest(
    string Codigo,
    string Nombre,
    string Direccion,
    string Ciudad,
    string? Zona,
    string? Responsable,
    string? Telefono,
    decimal Latitud,
    decimal Longitud,
    int GeofenceMetros)
{
    public UpsertFarmaciaRequest Normalize() => this with
    {
        Codigo = Codigo.Trim(),
        Nombre = Nombre.Trim(),
        Direccion = Direccion.Trim(),
        Ciudad = Ciudad.Trim(),
        Zona = string.IsNullOrWhiteSpace(Zona) ? null : Zona.Trim(),
        Responsable = string.IsNullOrWhiteSpace(Responsable) ? null : Responsable.Trim(),
        Telefono = string.IsNullOrWhiteSpace(Telefono) ? null : Telefono.Trim(),
        GeofenceMetros = GeofenceMetros <= 0 ? 100 : GeofenceMetros,
    };
}

public sealed record AsignacionFarmaciaDto(
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

public sealed record CreateAsignacionRequest(
    string FarmaciaId,
    string UsuarioId,
    DateTime FechaPlaneada,
    string? Observaciones);

public sealed record RolDto(string Id, string Nombre, string Descripcion, bool Activo, DateTime CreatedAt);

public sealed record PermisoDto(string Id, string Nombre, string Modulo, string Accion, string Descripcion);

public sealed record AuditoriaDto(
    string Id,
    string Accion,
    string Modulo,
    string? EntidadAfectada,
    string? IpAddress,
    bool Exitoso,
    string? MensajeError,
    DateTime CreatedAt);

public sealed record PagedResultDto<T>(
    IEnumerable<T> Items,
    int TotalCount,
    int Page,
    int PageSize)
{
    public int TotalPages => (int)Math.Ceiling(TotalCount / (double)PageSize);
}

public sealed record CreateUsuarioRequest(
    string Nombre,
    string Apellido,
    string Email,
    string Username,
    string Password,
    string Rol,
    string? ZonaId);

public sealed record UpdateUsuarioRequest(
    string Nombre,
    string Apellido,
    string Email,
    string Username,
    string Rol,
    string? ZonaId);

public sealed record CambiarPasswordRequest(
    string Password);
