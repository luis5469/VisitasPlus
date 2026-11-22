using MediatR;
using Microsoft.Extensions.Configuration;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Visitas.Commands;
using VisitaPDV.Application.Features.Visitas.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Visitas.Handlers;

public sealed class IniciarVisitaHandler(
    IPdvRepository     pdvRepo,
    IVisitaRepository  visitaRepo,
    IUnitOfWork        uow,
    IConfiguration     configuration)
    : IRequestHandler<IniciarVisitaCommand, VisitaDto>
{
    public async Task<VisitaDto> Handle(IniciarVisitaCommand cmd, CancellationToken ct)
    {
        // 1. Verificar que no hay visita activa
        var activa = await visitaRepo.GetVisitaActivaAsync(cmd.VisitadorId, ct);
        if (activa is not null)
            throw new InvalidOperationException(
                "Ya tienes una visita en curso. Finalízala antes de iniciar otra.");

        // 2. Verificar PDV existe
        var pdv = await pdvRepo.GetByIdAsync(cmd.PdvId, ct)
            ?? throw new KeyNotFoundException($"PDV {cmd.PdvId} no encontrado.");

        if (!pdv.Activo)
            throw new InvalidOperationException("El PDV está inactivo.");

        // 3. Validar geofence
        var isTesting = string.Equals(configuration["AppSettings:IsTesting"], "true", StringComparison.OrdinalIgnoreCase);
        if (!isTesting && !pdv.EstaDentroDeGeofence(cmd.Latitud, cmd.Longitud))
            throw new InvalidOperationException(
                $"Debes estar a menos de {pdv.GeofenceMetros} m del PDV para iniciar la visita.");

        // 4. Crear visita
        var visita = Visita.Create(cmd.PdvId, cmd.VisitadorId, cmd.Latitud, cmd.Longitud);
        await visitaRepo.AddAsync(visita, ct);
        await uow.SaveChangesAsync(ct);

        return MapToDto(visita, pdv, null);
    }

    private static VisitaDto MapToDto(Visita v, Pdv pdv, string? visitadorNombre) => new(
        v.Id, v.PdvId, pdv.Nombre, pdv.Codigo,
        v.VisitadorId, visitadorNombre ?? string.Empty,
        v.Estado.ToString(),
        v.LatitudInicio, v.LongitudInicio,
        v.LatitudFin,    v.LongitudFin,
        v.TimestampInicio, v.TimestampFin,
        v.ActaPdfUrl, v.Sincronizado);
}

public sealed class FinalizarVisitaHandler(
    IPdvRepository    pdvRepo,
    IVisitaRepository visitaRepo,
    IUnitOfWork       uow,
    IConfiguration    configuration)
    : IRequestHandler<FinalizarVisitaCommand, VisitaDto>
{
    public async Task<VisitaDto> Handle(FinalizarVisitaCommand cmd, CancellationToken ct)
    {
        var visita = await visitaRepo.GetConDetallesAsync(cmd.VisitaId, ct)
            ?? throw new KeyNotFoundException($"Visita {cmd.VisitaId} no encontrada.");

        if (visita.VisitadorId != cmd.VisitadorId)
            throw new UnauthorizedAccessException("No puedes finalizar una visita de otro visitador.");

        if (visita.Estado == Domain.Enums.VisitStatus.Completada)
            throw new InvalidOperationException("La visita ya fue finalizada.");

        var pdv = await pdvRepo.GetByIdAsync(visita.PdvId, ct)!;

        // Validar geofence al finalizar
        var isTesting = string.Equals(configuration["AppSettings:IsTesting"], "true", StringComparison.OrdinalIgnoreCase);
        if (!isTesting && pdv is not null && !pdv.EstaDentroDeGeofence(cmd.Latitud, cmd.Longitud))
            throw new InvalidOperationException(
                $"Debes estar a menos de {pdv!.GeofenceMetros} m del PDV para finalizar la visita.");

        visita.Finalizar(cmd.Latitud, cmd.Longitud);
        visitaRepo.Update(visita);
        await uow.SaveChangesAsync(ct);

        return new VisitaDto(
            visita.Id, visita.PdvId, pdv?.Nombre ?? string.Empty, pdv?.Codigo ?? string.Empty,
            visita.VisitadorId, string.Empty,
            visita.Estado.ToString(),
            visita.LatitudInicio, visita.LongitudInicio,
            visita.LatitudFin, visita.LongitudFin,
            visita.TimestampInicio, visita.TimestampFin,
            visita.ActaPdfUrl, visita.Sincronizado);
    }
}
