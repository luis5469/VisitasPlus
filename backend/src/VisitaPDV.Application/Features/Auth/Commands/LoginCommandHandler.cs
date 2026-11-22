using MediatR;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Auth.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Application.Features.Auth.Commands;

public sealed class LoginCommandHandler(
    IUsuarioRepository usuarioRepo,
    IRefreshTokenRepository refreshRepo,
    IDispositivoRepository dispositivoRepo,
    ITokenService tokenService,
    IPasswordHasher passwordHasher,
    IAuditoriaService auditoria,
    IUnitOfWork uow)
    : IRequestHandler<LoginCommand, LoginResponse>
{
    private static readonly TimeSpan AccessTokenExpiry = TimeSpan.FromHours(8);
    private static readonly TimeSpan RefreshTokenExpiry = TimeSpan.FromDays(30);

    public async Task<LoginResponse> Handle(
        LoginCommand request, CancellationToken cancellationToken)
    {
        var usuario = await usuarioRepo.GetByUsernameOrEmailAsync(
            request.UsernameOrEmail, cancellationToken)
            ?? throw new NotFoundException(nameof(Usuario), request.UsernameOrEmail);

        // Bloqueo por intentos fallidos
        if (usuario.IsBlocked())
            throw new DomainException(
                $"Cuenta bloqueada. Intente nuevamente después de {usuario.BloqueadoHasta:HH:mm} UTC.");

        // Verificación de contraseña
        if (!passwordHasher.Verify(request.Password, usuario.PasswordHash))
        {
            usuario.RegisterFailedAttempt();
            usuarioRepo.Update(usuario);
            await uow.SaveChangesAsync(cancellationToken);

            await auditoria.RegistrarAsync(
                "AUTH", "LOGIN_FALLIDO", false,
                usuario.Id, nameof(Usuario), usuario.Id.ToString(),
                mensajeError: "Contraseña incorrecta");

            throw new DomainException(
                usuario.IsBlocked()
                    ? "Cuenta bloqueada por 5 intentos fallidos. Intente en 30 minutos."
                    : "Credenciales incorrectas.");
        }

        if (!usuario.Activo)
            throw new DomainException("El usuario está inactivo. Contacte al administrador.");

        // Registro dispositivo
        string? dispositivoId = null;
        if (!string.IsNullOrEmpty(request.DeviceId))
        {
            var dispositivo = await dispositivoRepo.GetByDeviceIdAsync(
                request.DeviceId, cancellationToken);

            if (dispositivo is null)
            {
                dispositivo = Dispositivo.Create(
                    usuario.Id,
                    request.DeviceId,
                    request.DeviceName ?? "Desconocido",
                    request.Plataforma ?? "Desconocido");
                await dispositivoRepo.AddAsync(dispositivo, cancellationToken);
            }
            else
            {
                dispositivo.RegistrarAcceso();
                dispositivoRepo.Update(dispositivo);
            }
            dispositivoId = dispositivo.Id;
        }

        // Revocar tokens anteriores del dispositivo
        await refreshRepo.RevokeAllByUsuarioAsync(
            usuario.Id, "Nuevo login", cancellationToken);

        // Generar tokens
        var jwtId = Guid.NewGuid().ToString();
        var accessToken = tokenService.GenerateAccessToken(usuario, jwtId);
        var rawRefresh = tokenService.GenerateRefreshToken();

        var refreshToken = RefreshToken.Create(
            usuario.Id,
            rawRefresh,
            jwtId,
            DateTime.UtcNow.Add(RefreshTokenExpiry),
            request.IpAddress,
            request.UserAgent,
            dispositivoId);

        await refreshRepo.AddAsync(refreshToken, cancellationToken);

        usuario.RecordLogin();
        usuarioRepo.Update(usuario);
        await uow.SaveChangesAsync(cancellationToken);

        await auditoria.RegistrarAsync(
            "AUTH", "LOGIN_OK", true,
            usuario.Id, nameof(Usuario), usuario.Id.ToString());

        return new LoginResponse(
            accessToken,
            rawRefresh,
            DateTime.UtcNow.Add(AccessTokenExpiry),
            usuario.Id.ToString(),
            usuario.Username,
            usuario.NombreCompleto,
            usuario.Rol.ToString());
    }
}
