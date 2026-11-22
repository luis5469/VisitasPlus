using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Auth.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Exceptions;

namespace VisitaPDV.Application.Features.Auth.Queries;

public sealed class GetMeQueryHandler(IUsuarioRepository usuarioRepo)
    : IRequestHandler<GetMeQuery, MeResponse>
{
    public async Task<MeResponse> Handle(
        GetMeQuery request, CancellationToken cancellationToken)
    {
        var usuario = await usuarioRepo.GetByIdAsync(request.UsuarioId, cancellationToken)
            ?? throw new NotFoundException(nameof(Usuario), request.UsuarioId);

        return new MeResponse(
            usuario.Id,
            usuario.Username,
            usuario.NombreCompleto,
            usuario.Email,
            usuario.Rol.ToString(),
            usuario.UltimoLogin,
            usuario.BiometriaHabilitada);
    }
}
