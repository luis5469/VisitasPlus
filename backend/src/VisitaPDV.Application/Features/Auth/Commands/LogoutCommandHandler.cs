using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Auth.Commands;

public sealed class LogoutCommandHandler(
    IRefreshTokenRepository refreshRepo,
    IAuditoriaService auditoria,
    IUnitOfWork uow)
    : IRequestHandler<LogoutCommand, Unit>
{
    public async Task<Unit> Handle(
        LogoutCommand request, CancellationToken cancellationToken)
    {
        var token = await refreshRepo.GetByTokenAsync(request.RefreshToken, cancellationToken);

        if (token is not null && token.IsActive())
        {
            token.Revoke("Logout del usuario");
            await uow.SaveChangesAsync(cancellationToken);
        }

        await auditoria.RegistrarAsync(
            "AUTH", "LOGOUT", true,
            request.UsuarioId);

        return Unit.Value;
    }
}
