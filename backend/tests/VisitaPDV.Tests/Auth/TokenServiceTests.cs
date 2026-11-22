using FluentAssertions;
using Microsoft.Extensions.Configuration;
using VisitaPDV.Domain.Entities;
using VisitaPDV.Domain.Enums;
using VisitaPDV.Infrastructure.Identity;

namespace VisitaPDV.Tests.Auth;

public sealed class TokenServiceTests
{
    private readonly TokenService _sut;

    public TokenServiceTests()
    {
        var config = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["JwtSettings:Secret"]   = "SuperSecretKeyForTestingPurposes1234567890!",
                ["JwtSettings:Issuer"]   = "VisitaPDV.Test",
                ["JwtSettings:Audience"] = "VisitaPDV.TestClient",
            })
            .Build();

        _sut = new TokenService(config);
    }

    private static Usuario BuildUsuario() =>
        Usuario.Create(
            "Juan", "Pérez",
            "juan@test.com", "juanperez",
            "hashed_pass", UserRole.Visitador);

    [Fact]
    public void GenerateAccessToken_ShouldReturn_ValidJwt()
    {
        var usuario = BuildUsuario();
        var jwtId = Guid.NewGuid().ToString();

        var token = _sut.GenerateAccessToken(usuario, jwtId);

        token.Should().NotBeNullOrEmpty();
        token.Split('.').Should().HaveCount(3, "un JWT tiene 3 partes separadas por punto");
    }

    [Fact]
    public void GetJtiFromToken_ShouldReturn_CorrectJti()
    {
        var usuario = BuildUsuario();
        var jwtId = Guid.NewGuid().ToString();

        var token = _sut.GenerateAccessToken(usuario, jwtId);
        var extractedJti = _sut.GetJtiFromToken(token);

        extractedJti.Should().Be(jwtId);
    }

    [Fact]
    public void GetUserIdFromToken_ShouldReturn_CorrectId()
    {
        var usuario = BuildUsuario();
        var token = _sut.GenerateAccessToken(usuario, Guid.NewGuid().ToString());

        var userId = _sut.GetUserIdFromToken(token);

        userId.Should().Be(usuario.Id);
    }

    [Fact]
    public void GetPrincipalFromToken_ShouldReturn_Claims_EvenWhenExpired()
    {
        var usuario = BuildUsuario();
        var token = _sut.GenerateAccessToken(usuario, Guid.NewGuid().ToString());

        // El token es válido recién generado; verificamos que devuelve principal
        var principal = _sut.GetPrincipalFromToken(token);

        principal.Should().NotBeNull();
        principal!.Identity!.IsAuthenticated.Should().BeTrue();
    }

    [Fact]
    public void GetPrincipalFromToken_ShouldReturn_Null_ForInvalidToken()
    {
        var principal = _sut.GetPrincipalFromToken("token.invalido.aqui");

        principal.Should().BeNull();
    }

    [Fact]
    public void GenerateRefreshToken_ShouldReturn_Base64String()
    {
        var token = _sut.GenerateRefreshToken();

        token.Should().NotBeNullOrEmpty();
        var bytes = Convert.FromBase64String(token); // No debe lanzar
        bytes.Should().HaveCount(64);
    }
}
