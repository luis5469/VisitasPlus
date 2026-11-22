using FluentAssertions;
using MediatR;
using Moq;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Auth.Commands;
using VisitaPDV.Application.Features.Auth.Dtos;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Tests.Auth;

public sealed class LoginCommandHandlerTests
{
    private readonly Mock<IUsuarioRepository> _usuarioRepo = new();
    private readonly Mock<IRefreshTokenRepository> _refreshRepo = new();
    private readonly Mock<IDispositivoRepository> _dispositivoRepo = new();
    private readonly Mock<ITokenService> _tokenService = new();
    private readonly Mock<IPasswordHasher> _passwordHasher = new();
    private readonly Mock<IAuditoriaService> _auditoria = new();
    private readonly Mock<IUnitOfWork> _uow = new();

    private LoginCommandHandler CreateSut() => new(
        _usuarioRepo.Object,
        _refreshRepo.Object,
        _dispositivoRepo.Object,
        _tokenService.Object,
        _passwordHasher.Object,
        _auditoria.Object,
        _uow.Object);

    private static Usuario BuildActiveUser(string username = "testuser") =>
        Usuario.Create("Juan", "Pérez", $"{username}@test.com", username,
            "$2a$12$hashedpassword", UserRole.Visitador);

    [Fact]
    public async Task Handle_ShouldReturn_LoginResponse_WhenCredentialsAreValid()
    {
        var usuario = BuildActiveUser();
        var command = new LoginCommand("testuser", "Password123!");

        _usuarioRepo.Setup(r => r.GetByUsernameOrEmailAsync("testuser", default))
            .ReturnsAsync(usuario);
        _passwordHasher.Setup(h => h.Verify("Password123!", usuario.PasswordHash))
            .Returns(true);
        _tokenService.Setup(t => t.GenerateAccessToken(usuario, It.IsAny<string>()))
            .Returns("access_token_jwt");
        _tokenService.Setup(t => t.GenerateRefreshToken())
            .Returns("refresh_token_base64");
        _refreshRepo.Setup(r => r.RevokeAllByUsuarioAsync(usuario.Id, It.IsAny<string>(), default))
            .Returns(Task.CompletedTask);
        _refreshRepo.Setup(r => r.AddAsync(It.IsAny<RefreshToken>(), default))
            .Returns(Task.CompletedTask);
        _uow.Setup(u => u.SaveChangesAsync(default)).ReturnsAsync(1);
        _auditoria.Setup(a => a.RegistrarAsync(It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<bool>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(),
            It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), default))
            .Returns(Task.CompletedTask);

        var result = await CreateSut().Handle(command, default);

        result.Should().NotBeNull();
        result.AccessToken.Should().Be("access_token_jwt");
        result.RefreshToken.Should().Be("refresh_token_base64");
        result.Username.Should().Be("testuser");
    }

    [Fact]
    public async Task Handle_ShouldThrow_WhenUserNotFound()
    {
        _usuarioRepo.Setup(r => r.GetByUsernameOrEmailAsync("ghost", default))
            .ReturnsAsync((Usuario?)null);

        var command = new LoginCommand("ghost", "pass");

        await CreateSut().Invoking(h => h.Handle(command, default))
            .Should().ThrowAsync<NotFoundException>();
    }

    [Fact]
    public async Task Handle_ShouldThrow_WhenPasswordIsWrong()
    {
        var usuario = BuildActiveUser();
        _usuarioRepo.Setup(r => r.GetByUsernameOrEmailAsync("testuser", default))
            .ReturnsAsync(usuario);
        _passwordHasher.Setup(h => h.Verify("wrong", usuario.PasswordHash))
            .Returns(false);
        _usuarioRepo.Setup(r => r.Update(usuario));
        _uow.Setup(u => u.SaveChangesAsync(default)).ReturnsAsync(1);
        _auditoria.Setup(a => a.RegistrarAsync(It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<bool>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(),
            It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), default))
            .Returns(Task.CompletedTask);

        var command = new LoginCommand("testuser", "wrong");

        await CreateSut().Invoking(h => h.Handle(command, default))
            .Should().ThrowAsync<DomainException>();
    }

    [Fact]
    public async Task Handle_ShouldThrow_WhenUserIsBlocked()
    {
        var usuario = BuildActiveUser();
        // Simular 5 intentos fallidos para bloquear
        for (int i = 0; i < 5; i++) usuario.RegisterFailedAttempt();

        _usuarioRepo.Setup(r => r.GetByUsernameOrEmailAsync("testuser", default))
            .ReturnsAsync(usuario);

        var command = new LoginCommand("testuser", "any");

        await CreateSut().Invoking(h => h.Handle(command, default))
            .Should().ThrowAsync<DomainException>()
            .WithMessage("*bloqueada*");
    }
}
