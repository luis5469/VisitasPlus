using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Auth.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Auth.Commands;

public sealed class RefreshTokenCommandHandler(
    IUsuarioRepository usuarioRepo,
    IRefreshTokenRepository refreshRepo,
    ITokenService tokenService,
    IAuditoriaService auditoria,
    IUnitOfWork uow)
    : IRequestHandler<RefreshTokenCommand, LoginResponse>
{
    private static readonly TimeSpan AccessTokenExpiry = TimeSpan.FromHours(8);
    private static readonly TimeSpan RefreshTokenExpiry = TimeSpan.FromDays(30);

    public async Task<LoginResponse> Handle(
        RefreshTokenCommand request, CancellationToken cancellationToken)
    {
        // Validar el access token (aceptamos expirado)
        var principal = tokenService.GetPrincipalFromToken(request.AccessToken)
            ?? throw new DomainException("Token de acceso inválido.");

        var jti = tokenService.GetJtiFromToken(request.AccessToken)
            ?? throw new DomainException("Token sin JTI.");

        var storedToken = await refreshRepo.GetByTokenAsync(
            request.RefreshToken, cancellationToken)
            ?? throw new DomainException("Refresh token no encontrado.");

        if (!storedToken.IsActive())
            throw new DomainException("Refresh token expirado o revocado.");

        if (storedToken.JwtId != jti)
            throw new DomainException("Refresh token no corresponde al access token.");

        var usuario = await usuarioRepo.GetByIdAsync(storedToken.UsuarioId, cancellationToken)
            ?? throw new NotFoundException(nameof(Usuario), storedToken.UsuarioId);

        if (!usuario.Activo)
            throw new DomainException("Usuario inactivo.");

        // Rotar tokens
        storedToken.MarkAsUsed();

        var newJwtId = Guid.NewGuid().ToString();
        var newAccess = tokenService.GenerateAccessToken(usuario, newJwtId);
        var newRawRefresh = tokenService.GenerateRefreshToken();

        var newRefresh = RefreshToken.Create(
            usuario.Id,
            newRawRefresh,
            newJwtId,
            DateTime.UtcNow.Add(RefreshTokenExpiry),
            request.IpAddress,
            request.UserAgent,
            storedToken.DispositivoId);

        await refreshRepo.AddAsync(newRefresh, cancellationToken);
        await uow.SaveChangesAsync(cancellationToken);

        await auditoria.RegistrarAsync(
            "AUTH", "REFRESH_TOKEN", true,
            usuario.Id, nameof(Usuario), usuario.Id.ToString());

        return new LoginResponse(
            newAccess,
            newRawRefresh,
            DateTime.UtcNow.Add(AccessTokenExpiry),
            usuario.Id.ToString(),
            usuario.Username,
            usuario.NombreCompleto,
            usuario.Rol.ToString());
    }
}
