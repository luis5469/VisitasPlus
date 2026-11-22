using MediatR;
using VisitaPDV.Application.Features.Novedades.Dtos;
using VisitaPDV.Application.Features.Novedades.Queries;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Novedades.Handlers;

public sealed class GetNovedadByIdHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadByIdQuery, NovedadDto?>
{
    public async Task<NovedadDto?> Handle(GetNovedadByIdQuery q, CancellationToken ct)
    {
        var n = await repo.GetConDetallesAsync(q.Id, ct);
        return n is null ? null : NovedadMapper.ToDto(n);
    }
}

public sealed class GetNovedadesByVisitaHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadesByVisitaQuery, List<NovedadListDto>>
{
    public async Task<List<NovedadListDto>> Handle(GetNovedadesByVisitaQuery q, CancellationToken ct)
    {
        var lista = await repo.GetByVisitaAsync(q.VisitaId, ct);
        return lista.Select(NovedadMapper.ToListDto).ToList();
    }
}

public sealed class GetNovedadesByPdvHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadesByPdvQuery, List<NovedadListDto>>
{
    public async Task<List<NovedadListDto>> Handle(GetNovedadesByPdvQuery q, CancellationToken ct)
    {
        var lista = await repo.GetByPdvAsync(q.PdvId, ct);
        return lista.Select(NovedadMapper.ToListDto).ToList();
    }
}

public sealed class GetNovedadesByResponsableHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadesByResponsableQuery, List<NovedadListDto>>
{
    public async Task<List<NovedadListDto>> Handle(GetNovedadesByResponsableQuery q, CancellationToken ct)
    {
        var lista = await repo.GetByResponsableAsync(q.UsuarioId, ct);
        return lista.Select(NovedadMapper.ToListDto).ToList();
    }
}

public sealed class GetNovedadesVencidasHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadesVencidasQuery, List<NovedadListDto>>
{
    public async Task<List<NovedadListDto>> Handle(GetNovedadesVencidasQuery q, CancellationToken ct)
    {
        var lista = await repo.GetVencidasAsync(ct);
        return lista.Select(NovedadMapper.ToListDto).ToList();
    }
}

public sealed class GetNovedadesPagedHandler(INovedadRepository repo)
    : IRequestHandler<GetNovedadesPagedQuery, NovedadesPagedResponse>
{
    public async Task<NovedadesPagedResponse> Handle(GetNovedadesPagedQuery q, CancellationToken ct)
    {
        var lista = await repo.GetByFiltroAsync(
            q.Estado, q.Categoria, q.Prioridad,
            q.PdvId, q.ResponsableId, q.Desde, q.Hasta,
            q.Pagina, q.Tamano, ct);

        var items = lista.Select(NovedadMapper.ToListDto).ToList();
        var totalItems = items.Count < q.Tamano
            ? (q.Pagina - 1) * q.Tamano + items.Count
            : q.Pagina * q.Tamano + 1;

        return new NovedadesPagedResponse(
            items, totalItems, q.Pagina, q.Tamano,
            (int)Math.Ceiling(totalItems / (double)q.Tamano));
    }
}

public sealed class GetSasUrlImagenHandler(INovedadRepository repo, IAzureBlobService blob)
    : IRequestHandler<GetSasUrlImagenQuery, string>
{
    public async Task<string> Handle(GetSasUrlImagenQuery q, CancellationToken ct)
    {
        var novedad = await repo.GetConDetallesAsync(q.NovedadId, ct)
            ?? throw new NotFoundException($"Novedad {q.NovedadId} no encontrada.");

        var imagen = novedad.Imagenes.FirstOrDefault(i => i.Id == q.ImagenId)
            ?? throw new NotFoundException($"Imagen {q.ImagenId} no encontrada.");

        var uri = new Uri(imagen.UrlImagen);
        var blobName = string.Join("/", uri.Segments.Skip(2)).TrimStart('/');
        return await blob.GetSasUrlAsync(blobName, validMinutes: q.ValidMinutes, ct: ct);
    }
}

