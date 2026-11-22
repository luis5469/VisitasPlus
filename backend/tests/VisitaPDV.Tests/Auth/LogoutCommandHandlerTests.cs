using FluentAssertions;
using MediatR;
using Moq;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Features.Auth.Commands;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Domain.Exceptions;
using VisitaPDV.Domain.Interfaces.Repositories;

namespace VisitaPDV.Tests.Auth;

public sealed class LogoutCommandHandlerTests
{
    private readonly Mock<IRefreshTokenRepository> _refreshRepo = new();
    private readonly Mock<IAuditoriaService> _auditoria = new();
    private readonly Mock<IUnitOfWork> _uow = new();

    private LogoutCommandHandler CreateSut() => new(
        _refreshRepo.Object, _auditoria.Object, _uow.Object);

    private static RefreshToken BuildActiveToken(string usuarioId) =>
        RefreshToken.Create(usuarioId, "raw_token", Guid.NewGuid().ToString(),
            DateTime.UtcNow.AddDays(30));

    [Fact]
    public async Task Handle_ShouldRevoke_ActiveRefreshToken()
    {
        var usuarioId = Guid.NewGuid().ToString();
        var token = BuildActiveToken(usuarioId);

        _refreshRepo.Setup(r => r.GetByTokenAsync("raw_token", default))
            .ReturnsAsync(token);
        _uow.Setup(u => u.SaveChangesAsync(default)).ReturnsAsync(1);
        _auditoria.Setup(a => a.RegistrarAsync(It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<bool>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(),
            It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), default))
            .Returns(Task.CompletedTask);

        var command = new LogoutCommand("raw_token", usuarioId);
        var result = await CreateSut().Handle(command, default);

        result.Should().Be(Unit.Value);
        token.IsRevoked.Should().BeTrue();
        _uow.Verify(u => u.SaveChangesAsync(default), Times.Once);
    }

    [Fact]
    public async Task Handle_ShouldSucceed_WhenTokenNotFound()
    {
        _refreshRepo.Setup(r => r.GetByTokenAsync("missing", default))
            .ReturnsAsync((RefreshToken?)null);
        _auditoria.Setup(a => a.RegistrarAsync(It.IsAny<string>(), It.IsAny<string>(),
            It.IsAny<bool>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(),
            It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), default))
            .Returns(Task.CompletedTask);

        var command = new LogoutCommand("missing", Guid.NewGuid().ToString());

        // No debe lanzar excepción
        await CreateSut().Invoking(h => h.Handle(command, default))
            .Should().NotThrowAsync();
    }
}
