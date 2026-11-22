using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using VisitaPDV.Application.Common.Interfaces;

namespace VisitaPDV.Infrastructure.Identity;

public sealed class CurrentUserService(IHttpContextAccessor httpContextAccessor)
    : ICurrentUserService
{
    private ClaimsPrincipal? User => httpContextAccessor.HttpContext?.User;

    public string UserId
    {
        get
        {
            return User?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? User?.FindFirstValue("sub")
                ?? string.Empty;
        }
    }

    public string Username =>
        User?.FindFirstValue(ClaimTypes.Name) ?? string.Empty;

    public string Role =>
        User?.FindFirstValue(ClaimTypes.Role) ?? string.Empty;

    public bool IsAuthenticated =>
        User?.Identity?.IsAuthenticated ?? false;
}
