using FluentAssertions;
using Moq;
using VisitaPDV.Infrastructure.Identity;

namespace VisitaPDV.Tests.Auth;

public sealed class PasswordHasherTests
{
    private readonly PasswordHasher _sut = new();

    [Fact]
    public void Hash_ShouldReturn_DifferentHashForSamePassword()
    {
        var hash1 = _sut.Hash("Password123!");
        var hash2 = _sut.Hash("Password123!");

        hash1.Should().NotBe(hash2); // BCrypt uses random salt
    }

    [Fact]
    public void Verify_ShouldReturn_True_ForCorrectPassword()
    {
        var password = "SecurePass@2024";
        var hash = _sut.Hash(password);

        _sut.Verify(password, hash).Should().BeTrue();
    }

    [Fact]
    public void Verify_ShouldReturn_False_ForWrongPassword()
    {
        var hash = _sut.Hash("CorrectPassword");

        _sut.Verify("WrongPassword", hash).Should().BeFalse();
    }

    [Fact]
    public void Hash_ShouldReturn_BcryptHash()
    {
        var hash = _sut.Hash("test");

        hash.Should().MatchRegex(@"^\$2[ab]\$");
    }
}
