using Microsoft.EntityFrameworkCore;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Dashboard.Dtos;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Infrastructure.Persistence;

namespace VisitaPDV.Infrastructure.Repositories;

public sealed class DashboardRepository(ApplicationDbContext context) : IDashboardRepository
{
    private static string BuildPdvPlaceholder(string pdvId) => $"Sin catalogo PDV ({(pdvId.Length > 8 ? pdvId[..8] : pdvId)})";

    public async Task<DashboardKpiDto> GetKpisAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default)
    {
        desde = DateTime.SpecifyKind(desde, DateTimeKind.Utc);
        hasta = DateTime.SpecifyKind(hasta, DateTimeKind.Utc);
        // Novedades abiertas (en cualquier estado no terminal)
        var novedadesAbiertas = await context.Novedades
            .CountAsync(n =>
                n.Estado != NovedadStatus.Resuelta &&
                n.Estado != NovedadStatus.Cerrada, ct);

        // Novedades vencidas
        var ahora = DateTime.UtcNow;
        var novedadesVencidas = await context.Novedades
            .CountAsync(n =>
                n.FechaSeguimiento < ahora &&
                n.Estado != NovedadStatus.Resuelta &&
                n.Estado != NovedadStatus.Cerrada, ct);

        // Tiempo promedio de resolución (horas) para novedades resueltas/cerradas en el rango
        var novedadesTiempos = await context.Novedades
            .Where(n =>
                (n.Estado == NovedadStatus.Resuelta || n.Estado == NovedadStatus.Cerrada) &&
                n.UpdatedAt >= desde && n.UpdatedAt <= hasta)
            .Select(n => new { n.CreatedAt, n.UpdatedAt })
            .ToListAsync(ct);

        var tiempoPromedio = novedadesTiempos.Count > 0
            ? novedadesTiempos.Average(n => (n.UpdatedAt - n.CreatedAt).TotalHours)
            : 0;

        // Visitas ejecutadas en el rango
        var visitasEjecutadas = await context.Visitas
            .CountAsync(v =>
                v.Estado == VisitStatus.Completada &&
                v.TimestampInicio >= desde && v.TimestampInicio <= hasta, ct);

        // Cumplimiento agenda
        var totalAgendado = await context.AgendaVisitas
            .CountAsync(a => a.FechaPlaneada >= desde && a.FechaPlaneada <= hasta, ct);

        var visitasCompletadasAgenda = await context.AgendaVisitas
            .CountAsync(a =>
                a.FechaPlaneada >= desde && a.FechaPlaneada <= hasta &&
                a.Completada, ct);

        var cumplimiento = totalAgendado > 0
            ? Math.Round((double)visitasCompletadasAgenda / totalAgendado * 100, 2)
            : 0;

        // Total novedades en el rango
        var totalNovedades = await context.Novedades
            .CountAsync(n => n.CreatedAt >= desde && n.CreatedAt <= hasta, ct);

        return new DashboardKpiDto(
            NovedadesAbiertas:              novedadesAbiertas,
            NovedadesVencidas:              novedadesVencidas,
            TiempoResolucionPromedioHoras:  Math.Round(tiempoPromedio, 1),
            VisitasEjecutadas:              visitasEjecutadas,
            PorcentajeCumplimientoAgenda:   cumplimiento,
            TotalAgendado:                  totalAgendado,
            TotalNovedades:                 totalNovedades,
            GeneradoEn:                     DateTime.UtcNow
        );
    }

    public async Task<IEnumerable<IncidenciaCategoriaDto>> GetIncidenciasPorCategoriaAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default)
    {
        var ahora = DateTime.UtcNow;

        var novedades = await context.Novedades
            .Where(n => n.CreatedAt >= desde && n.CreatedAt <= hasta)
            .Select(n => new { n.Categoria, n.Estado, n.FechaSeguimiento })
            .ToListAsync(ct);

        return novedades
            .GroupBy(n => n.Categoria)
            .Select(g => new IncidenciaCategoriaDto(
                Categoria: g.Key,
                Total: g.Count(),
                Abiertas: g.Count(n =>
                    n.Estado != NovedadStatus.Resuelta &&
                    n.Estado != NovedadStatus.Cerrada),
                Resueltas: g.Count(n =>
                    n.Estado == NovedadStatus.Resuelta ||
                    n.Estado == NovedadStatus.Cerrada),
                Vencidas: g.Count(n =>
                    n.FechaSeguimiento < ahora &&
                    n.Estado != NovedadStatus.Resuelta &&
                    n.Estado != NovedadStatus.Cerrada)
            ))
            .OrderByDescending(x => x.Total)
            .ToList();
    }

    public async Task<IEnumerable<VisitadorEficienciaDto>> GetEficienciaPorVisitadorAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default)
    {
        var visitas = await context.Visitas
            .Where(v => v.TimestampInicio >= desde && v.TimestampInicio <= hasta)
            .Select(v => new
            {
                v.VisitadorId,
                Nombre = v.Visitador.Nombre,
                Apellido = v.Visitador.Apellido,
                v.Estado,
                v.TimestampInicio,
                v.TimestampFin
            })
            .ToListAsync(ct);

        var visitasGrupo = visitas
            .GroupBy(v => new { v.VisitadorId, v.Nombre, v.Apellido })
            .Select(g => new
            {
                g.Key.VisitadorId,
                NombreCompleto = g.Key.Nombre + " " + g.Key.Apellido,
                VisitasCompletadas = g.Count(v => v.Estado == VisitStatus.Completada),
                TiempoPromedioMin = g
                    .Where(v => v.Estado == VisitStatus.Completada && v.TimestampFin.HasValue)
                    .Select(v => (v.TimestampFin!.Value - v.TimestampInicio).TotalMinutes)
                    .DefaultIfEmpty(0)
                    .Average()
            })
            .ToList();

        // Agenda por visitador
        var agendaGrupo = await context.AgendaVisitas
            .Where(a => a.FechaPlaneada >= desde && a.FechaPlaneada <= hasta)
            .GroupBy(a => a.VisitadorId)
            .Select(g => new
            {
                VisitadorId      = g.Key,
                TotalAgendado    = g.Count(),
                TotalCompletados = g.Count(a => a.Completada)
            })
            .ToListAsync(ct);

        // Novedades por visitador (a través de visita)
        var novedades = await context.Novedades
            .Where(n => n.CreatedAt >= desde && n.CreatedAt <= hasta)
            .Select(n => new
            {
                VisitadorId = n.Visita.VisitadorId,
                n.Estado
            })
            .ToListAsync(ct);

        var novedadesGrupo = novedades
            .GroupBy(n => n.VisitadorId)
            .Select(g => new
            {
                VisitadorId = g.Key,
                TotalNovedades = g.Count(),
                NovedadesResueltas = g.Count(n =>
                    n.Estado == NovedadStatus.Resuelta ||
                    n.Estado == NovedadStatus.Cerrada)
            })
            .ToList();

        var agendaDict   = agendaGrupo.ToDictionary(x => x.VisitadorId);
        var novedadesDict = novedadesGrupo.ToDictionary(x => x.VisitadorId);

        return visitasGrupo.Select(v =>
        {
            var agenda   = agendaDict.GetValueOrDefault(v.VisitadorId);
            var novedades = novedadesDict.GetValueOrDefault(v.VisitadorId);
            var agendado = agenda?.TotalAgendado ?? 0;
            var cumplimiento = agendado > 0
                ? Math.Round((double)(agenda?.TotalCompletados ?? 0) / agendado * 100, 2)
                : 0;

            return new VisitadorEficienciaDto(
                VisitadorId:               v.VisitadorId,
                NombreCompleto:            v.NombreCompleto,
                VisitasCompletadas:        v.VisitasCompletadas,
                VisitasAgendadas:          agendado,
                PorcentajeCumplimiento:    cumplimiento,
                NovedadesRegistradas:      novedades?.TotalNovedades ?? 0,
                NovedadesResueltas:        novedades?.NovedadesResueltas ?? 0,
                TiempoPromedioVisitaMinutos: Math.Round(v.TiempoPromedioMin, 1)
            );
        }).OrderByDescending(x => x.PorcentajeCumplimiento);
    }

    public async Task<IEnumerable<HeatmapPuntoDto>> GetHeatmapPuntosAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default)
    {
        var puntos = await context.Visitas
            .Where(v => v.TimestampInicio >= desde && v.TimestampInicio <= hasta)
            .GroupBy(v => v.PdvId)
            .Select(g => new
            {
                PdvId   = g.Key,
                Visitas = g.Count()
            })
            .ToListAsync(ct);

        // Novedades abiertas por PDV
        var novedadesAbiertas = await context.Novedades
            .Where(n =>
                n.Estado != NovedadStatus.Resuelta &&
                 n.Estado != NovedadStatus.Cerrada)
            .GroupBy(n => n.PdvId)
            .Select(g => new { PdvId = g.Key, Abiertas = g.Count() })
            .ToDictionaryAsync(x => x.PdvId, x => x.Abiertas, ct);

        // Nombres de PDV
        var pdvIds = puntos.Select(p => p.PdvId).Distinct().ToList();
        var pdvs = await context.Pdvs
            .Where(p => pdvIds.Contains(p.Id))
            .Select(p => new { p.Id, p.Nombre })
            .ToDictionaryAsync(p => p.Id, p => p.Nombre, ct);

        return puntos.Select(p => new HeatmapPuntoDto(
            NombrePdv:       pdvs.GetValueOrDefault(p.PdvId) ?? BuildPdvPlaceholder(p.PdvId),
            Latitud:         0,
            Longitud:        0,
            CantidadVisitas: p.Visitas,
            NovedadesAbiertas: novedadesAbiertas.GetValueOrDefault(p.PdvId, 0)
        ));
    }

    public async Task<IEnumerable<AlertaDashboardDto>> GetAlertasActivasAsync(
        CancellationToken ct = default)
    {
        var ahora = DateTime.UtcNow;

        var alertas = await context.Novedades
            .Where(n =>
                n.FechaSeguimiento < ahora &&
                n.Estado != NovedadStatus.Resuelta &&
                n.Estado != NovedadStatus.Cerrada)
            .OrderBy(n => n.FechaSeguimiento)
            .Take(50)
            .Select(n => new
            {
                n.Id,
                n.Titulo,
                n.Categoria,
                n.Prioridad,
                n.FechaSeguimiento,
                n.PdvId,
                ResponsableSolucionId = n.ResponsableSolucionId
            })
            .ToListAsync(ct);

        // Nombres de responsables
        var responsableIds = alertas.Select(a => a.ResponsableSolucionId).Distinct().ToList();
        var responsables   = await context.Usuarios
            .Where(u => responsableIds.Contains(u.Id))
            .Select(u => new { u.Id, Nombre = u.Nombre + " " + u.Apellido })
            .ToDictionaryAsync(u => u.Id, u => u.Nombre, ct);

        // Nombres de PDV
        var pdvIds = alertas.Select(a => a.PdvId).Distinct().ToList();
        var pdvs = await context.Pdvs
            .Where(p => pdvIds.Contains(p.Id))
            .Select(p => new { p.Id, p.Nombre })
            .ToDictionaryAsync(p => p.Id, p => p.Nombre, ct);

        return alertas.Select(a => new AlertaDashboardDto(
            NovedadId:          a.Id,
            Titulo:             a.Titulo,
            Categoria:          a.Categoria,
            Prioridad:          a.Prioridad,
            FechaSeguimiento:   a.FechaSeguimiento,
            DiasVencida:        (int)(ahora - a.FechaSeguimiento).TotalDays,
            NombrePdv:          pdvs.GetValueOrDefault(a.PdvId) ?? BuildPdvPlaceholder(a.PdvId),
            ResponsableNombre:  responsables.GetValueOrDefault(a.ResponsableSolucionId, "Sin asignar")
        ));
    }

    public async Task<IEnumerable<NovedadesTimelineDto>> GetNovedadesTimelineAsync(
        DateTime desde, DateTime hasta, CancellationToken ct = default)
    {
        var novedades = await context.Novedades
            .Where(n => n.CreatedAt >= desde && n.CreatedAt <= hasta)
            .Select(n => new
            {
                Fecha  = n.CreatedAt.Date,
                Estado = n.Estado
            })
            .ToListAsync(ct);

        var timeline = novedades
            .GroupBy(n => n.Fecha)
            .Select(g => new NovedadesTimelineDto(
                Fecha:      g.Key,
                Abiertas:   g.Count(n => n.Estado == NovedadStatus.Abierta || n.Estado == NovedadStatus.Reabierta),
                EnProgreso: g.Count(n => n.Estado == NovedadStatus.EnProgreso),
                Resueltas:  g.Count(n => n.Estado == NovedadStatus.Resuelta),
                Cerradas:   g.Count(n => n.Estado == NovedadStatus.Cerrada)
            ))
            .OrderBy(t => t.Fecha);

        return timeline;
    }
}
