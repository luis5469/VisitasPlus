using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Application.Common.Interfaces;

public interface IAuditoriaService
{
    Task RegistrarAsync(
        string modulo,
        string accion,
        bool exitoso,
        string? usuarioId = null,
        string? entidadAfectada = null,
        string? entidadId = null,
        string? detalleAnterior = null,
        string? detalleNuevo = null,
        string? mensajeError = null,
        CancellationToken ct = default);
}
