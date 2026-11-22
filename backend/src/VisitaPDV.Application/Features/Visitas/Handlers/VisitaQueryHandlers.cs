using MediatR;
using VisitaPDV.Application.Features.Visitas.Dtos;
using VisitaPDV.Application.Features.Visitas.Queries;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Visitas.Handlers;

public sealed class GetVisitasHandler(IVisitaRepository repo)
    : IRequestHandler<GetVisitasQuery, IEnumerable<VisitaDto>>
{
    public async Task<IEnumerable<VisitaDto>> Handle(GetVisitasQuery q, CancellationToken ct)
    {
        var visitas = await repo.GetByVisitadorAsync(q.VisitadorId, ct);
        return visitas.Select(v => new VisitaDto(
            v.Id, v.PdvId,
            v.Pdv?.Nombre ?? string.Empty, v.Pdv?.Codigo ?? string.Empty,
            v.VisitadorId, v.Visitador?.NombreCompleto ?? string.Empty,
            v.Estado.ToString(),
            v.LatitudInicio, v.LongitudInicio,
            v.LatitudFin, v.LongitudFin,
            v.TimestampInicio, v.TimestampFin,
            v.ActaPdfUrl, v.Sincronizado));
    }
}

public sealed class GetPdvsHandler(IPdvRepository repo, VisitaPDV.Application.Common.Interfaces.ICurrentUserService currentUser)
    : IRequestHandler<GetPdvsQuery, IEnumerable<PdvDto>>
{
    public async Task<IEnumerable<PdvDto>> Handle(GetPdvsQuery _, CancellationToken ct)
    {
        IEnumerable<Domain.Entities.Pdv> pdvs;
        if (currentUser.Role == "Visitador")
        {
            pdvs = await repo.GetAsignadosAsync(currentUser.UserId, ct);
        }
        else
        {
            pdvs = await repo.GetActivosAsync(ct);
        }
        return pdvs.Select(MapDto);
    }

    private static PdvDto MapDto(Domain.Entities.Pdv p) => new(
        p.Id, p.Codigo, p.Nombre, p.Direccion, p.Ciudad,
        p.Zona, p.Responsable, p.Telefono,
        p.Latitud, p.Longitud, p.GeofenceMetros, p.Activo);
}

public sealed class GetPdvByIdHandler(IPdvRepository repo)
    : IRequestHandler<GetPdvByIdQuery, PdvDto?>
{
    public async Task<PdvDto?> Handle(GetPdvByIdQuery q, CancellationToken ct)
    {
        var p = await repo.GetByIdAsync(q.Id, ct);
        if (p is null) return null;
        return new PdvDto(
            p.Id, p.Codigo, p.Nombre, p.Direccion, p.Ciudad,
            p.Zona, p.Responsable, p.Telefono,
            p.Latitud, p.Longitud, p.GeofenceMetros, p.Activo);
    }
}
