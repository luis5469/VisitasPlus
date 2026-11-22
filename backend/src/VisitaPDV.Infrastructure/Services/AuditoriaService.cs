using System.Text.Json;
using Microsoft.AspNetCore.Http;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Services;

public sealed class AuditoriaService(
    ApplicationDbContext context,
    IHttpContextAccessor httpContextAccessor)
    : IAuditoriaService
{
    public async Task RegistrarAsync(
        string modulo,
        string accion,
        bool exitoso,
        string? usuarioId = null,
        string? entidadAfectada = null,
        string? entidadId = null,
        string? detalleAnterior = null,
        string? detalleNuevo = null,
        string? mensajeError = null,
        CancellationToken ct = default)
    {
        var http = httpContextAccessor.HttpContext;
        var ip = http?.Connection.RemoteIpAddress?.ToString();
        var ua = http?.Request.Headers.UserAgent.ToString();

        var auditoria = Auditoria.Create(
            modulo, accion, exitoso,
            usuarioId, entidadAfectada, entidadId,
            detalleAnterior, detalleNuevo,
            ip ?? "desconocido", ua,
            mensajeError);

        await context.Set<Auditoria>().AddAsync(auditoria, ct);
        await context.SaveChangesAsync(ct);
    }
}
