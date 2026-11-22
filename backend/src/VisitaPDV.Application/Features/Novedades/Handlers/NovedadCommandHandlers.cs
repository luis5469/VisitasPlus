using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Novedades.Commands;
using VisitaPDV.Application.Features.Novedades.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Novedades.Handlers;

// ────────────────────────────────────────────────────────────────────────────
// CREAR
// ────────────────────────────────────────────────────────────────────────────
public sealed class CrearNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow,
    ICurrentUserService currentUser,
    IFirebaseNotificationService firebase,
    IDispositivoRepository dispositivoRepo,
    IAnonymizationService anonymizer)
    : IRequestHandler<CrearNovedadCommand, NovedadDto>
{
    public async Task<NovedadDto> Handle(CrearNovedadCommand cmd, CancellationToken ct)
    {
        var tituloAnonimo = await anonymizer.AnonymizeTextAsync(cmd.Titulo, ct);
        var descripcionAnonima = await anonymizer.AnonymizeTextAsync(cmd.Descripcion, ct);

        var novedad = Novedad.Create(
            cmd.VisitaId, cmd.PdvId,
            tituloAnonimo, descripcionAnonima,
            cmd.Categoria, cmd.Prioridad,
            cmd.ResponsableSolucionId, cmd.ResponsableSeguimientoId,
            cmd.FechaSeguimiento);

        await repo.AddAsync(novedad, ct);
        await uow.SaveChangesAsync(ct);

        // Push al responsable de solución
        var tokens = await dispositivoRepo.GetTokensByUsuarioAsync(cmd.ResponsableSolucionId, ct);
        if (tokens.Any())
            await firebase.SendMulticastAsync(tokens,
                "Nueva novedad asignada",
                $"Tienes una nueva novedad: {tituloAnonimo}",
                new Dictionary<string, string> { ["novedadId"] = novedad.Id.ToString(), ["tipo"] = "asignacion" },
                ct);

        return NovedadMapper.ToDto(novedad);
    }
}

// ────────────────────────────────────────────────────────────────────────────
// ACTUALIZAR
// ────────────────────────────────────────────────────────────────────────────
public sealed class ActualizarNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow,
    IAnonymizationService anonymizer)
    : IRequestHandler<ActualizarNovedadCommand, NovedadDto>
{
    public async Task<NovedadDto> Handle(ActualizarNovedadCommand cmd, CancellationToken ct)
    {
        var novedad = await repo.GetByIdAsync(cmd.Id, ct)
            ?? throw new NotFoundException($"Novedad {cmd.Id} no encontrada.");

        var tituloAnonimo = cmd.Titulo != null ? await anonymizer.AnonymizeTextAsync(cmd.Titulo, ct) : null;
        var descripcionAnonima = cmd.Descripcion != null ? await anonymizer.AnonymizeTextAsync(cmd.Descripcion, ct) : null;

        novedad.Actualizar(
            tituloAnonimo, descripcionAnonima, cmd.Categoria, cmd.Prioridad,
            cmd.ResponsableSolucionId, cmd.ResponsableSeguimientoId, cmd.FechaSeguimiento);

        repo.Update(novedad);
        await uow.SaveChangesAsync(ct);

        return NovedadMapper.ToDto(novedad);
    }
}

// ────────────────────────────────────────────────────────────────────────────
// CAMBIAR ESTADO
// ────────────────────────────────────────────────────────────────────────────
public sealed class CambiarEstadoNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow,
    ICurrentUserService currentUser,
    IFirebaseNotificationService firebase,
    IDispositivoRepository dispositivoRepo,
    IAnonymizationService anonymizer)
    : IRequestHandler<CambiarEstadoNovedadCommand, NovedadDto>
{
    public async Task<NovedadDto> Handle(CambiarEstadoNovedadCommand cmd, CancellationToken ct)
    {
        var novedad = await repo.GetByIdAsync(cmd.NovedadId, ct)
            ?? throw new NotFoundException($"Novedad {cmd.NovedadId} no encontrada.");

        if (!Enum.TryParse<NovedadStatus>(cmd.NuevoEstado, true, out var nuevoEstado))
            throw new DomainException($"Estado inválido: {cmd.NuevoEstado}");

        var estadoAnterior = novedad.Estado;
        var comentarioAnonimo = await anonymizer.AnonymizeTextAsync(cmd.Comentario, ct);
        novedad.CambiarEstado(nuevoEstado, currentUser.UserId, comentarioAnonimo);

        repo.Update(novedad);
        await uow.SaveChangesAsync(ct);

        // Push al responsable de seguimiento
        var tokens = await dispositivoRepo.GetTokensByUsuarioAsync(novedad.ResponsableSeguimientoId, ct);
        if (tokens.Any())
            await firebase.SendMulticastAsync(tokens,
                "Estado de novedad actualizado",
                $"\"{novedad.Titulo}\" cambió de {estadoAnterior} a {nuevoEstado}",
                new Dictionary<string, string>
                {
                    ["novedadId"] = novedad.Id.ToString(),
                    ["tipo"] = "cambio_estado",
                    ["estadoAnterior"] = estadoAnterior.ToString(),
                    ["estadoNuevo"] = nuevoEstado.ToString()
                },
                ct);

        return NovedadMapper.ToDto(novedad);
    }
}

// ────────────────────────────────────────────────────────────────────────────
// ELIMINAR
// ────────────────────────────────────────────────────────────────────────────
public sealed class EliminarNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow)
    : IRequestHandler<EliminarNovedadCommand, bool>
{
    public async Task<bool> Handle(EliminarNovedadCommand cmd, CancellationToken ct)
    {
        var novedad = await repo.GetByIdAsync(cmd.Id, ct)
            ?? throw new NotFoundException($"Novedad {cmd.Id} no encontrada.");

        repo.Remove(novedad);
        await uow.SaveChangesAsync(ct);
        return true;
    }
}

// ────────────────────────────────────────────────────────────────────────────
// SUBIR IMAGEN
// ────────────────────────────────────────────────────────────────────────────
public sealed class SubirImagenNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow,
    IAzureBlobService blob,
    ICurrentUserService currentUser)
    : IRequestHandler<SubirImagenNovedadCommand, SubirImagenResponse>
{
    private const long MaxBytes = 10 * 1024 * 1024; // 10 MB

    public async Task<SubirImagenResponse> Handle(SubirImagenNovedadCommand cmd, CancellationToken ct)
    {
        var novedad = await repo.GetByIdAsync(cmd.NovedadId, ct)
            ?? throw new NotFoundException($"Novedad {cmd.NovedadId} no encontrada.");

        if (cmd.ImagenStream.Length > MaxBytes)
            throw new DomainException("La imagen supera el tamaño máximo permitido de 10 MB.");

        // Nombre único con carpeta por novedadId
        var extension = Path.GetExtension(cmd.NombreArchivo).ToLowerInvariant();
        var blobName = $"{cmd.NovedadId}/{Guid.NewGuid()}{extension}";

        var url = await blob.UploadAsync(cmd.ImagenStream, blobName, cmd.ContentType, ct: ct);

        var imagen = NovedadImagen.Create(
            cmd.NovedadId, url, cmd.NombreArchivo,
            cmd.ImagenStream.Length, currentUser.UserId,
            cmd.Latitud, cmd.Longitud);

        novedad.AgregarImagen(imagen);
        repo.Update(novedad);
        await uow.SaveChangesAsync(ct);

        return new SubirImagenResponse(imagen.Id, url, cmd.NombreArchivo, cmd.ImagenStream.Length);
    }
}

// ────────────────────────────────────────────────────────────────────────────
// ELIMINAR IMAGEN
// ────────────────────────────────────────────────────────────────────────────
public sealed class EliminarImagenNovedadHandler(
    INovedadRepository repo,
    IUnitOfWork uow,
    IAzureBlobService blob)
    : IRequestHandler<EliminarImagenNovedadCommand, bool>
{
    public async Task<bool> Handle(EliminarImagenNovedadCommand cmd, CancellationToken ct)
    {
        var novedad = await repo.GetConDetallesAsync(cmd.NovedadId, ct)
            ?? throw new NotFoundException($"Novedad {cmd.NovedadId} no encontrada.");

        var imagen = novedad.Imagenes.FirstOrDefault(i => i.Id == cmd.ImagenId)
            ?? throw new NotFoundException($"Imagen {cmd.ImagenId} no encontrada.");

        // Extraer blobName del URL para borrar del storage
        var uri = new Uri(imagen.UrlImagen);
        var blobName = string.Join("/", uri.Segments.Skip(2)).TrimStart('/');
        await blob.DeleteAsync(blobName, ct: ct);

        novedad.RemoverImagen(cmd.ImagenId);
        repo.Update(novedad);
        await uow.SaveChangesAsync(ct);
        return true;
    }
}
