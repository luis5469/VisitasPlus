using Blazored.LocalStorage;
using Microsoft.AspNetCore.Components.Authorization;
using System.Security.Claims;
using VisitaPDV.Admin.Models;

namespace VisitaPDV.Admin.Services;

/// <summary>
/// Proveedor de autenticación para Blazor Server.
/// GetAuthenticationStateAsync retorna siempre el estado actual en memoria.
/// La sesión solo se establece al hacer login y se limpia al salir.
/// </summary>
public sealed class AdminAuthStateProvider(ILocalStorageService storage)
    : AuthenticationStateProvider
{
    private static readonly AuthenticationState Anonymous =
        new(new ClaimsPrincipal(new ClaimsIdentity()));

    // Estado actual en memoria — se actualiza al hidratar o al hacer login/logout
    private AuthenticationState _current = Anonymous;

    /// <summary>Retorna el estado en memoria. NUNCA llama JS → no cuelga en SSR.</summary>
    public override Task<AuthenticationState> GetAuthenticationStateAsync()
        => Task.FromResult(_current);

    /// <summary>
    /// Restaura la sesión desde localStorage si en el futuro se decide habilitar ese flujo.
    /// </summary>
    public async Task RehydrateAsync()
    {
        try
        {
            var session = await storage.GetItemAsync<LoginResponse>("login_response");
            _current = session is null ? Anonymous : Build(session);
        }
        catch
        {
            _current = Anonymous;
        }
        NotifyAuthenticationStateChanged(Task.FromResult(_current));
    }

    /// <summary>Registra la sesión en memoria y notifica al router.</summary>
    public async Task SignInAsync(LoginResponse session)
    {
        await storage.SetItemAsync("login_response", session);
        await storage.SetItemAsync("access_token",   session.AccessToken);
        await storage.SetItemAsync("refresh_token",  session.RefreshToken);
        _current = Build(session);
        NotifyAuthenticationStateChanged(Task.FromResult(_current));
    }

    /// <summary>Borra la sesión de memoria y localStorage.</summary>
    public async Task SignOutAsync()
    {
        try
        {
            await storage.RemoveItemAsync("login_response");
            await storage.RemoveItemAsync("access_token");
            await storage.RemoveItemAsync("refresh_token");
        }
        catch { }
        _current = Anonymous;
        NotifyAuthenticationStateChanged(Task.FromResult(_current));
    }

    private static AuthenticationState Build(LoginResponse s)
    {
        var userId = string.IsNullOrWhiteSpace(s.UserId) ? s.Username : s.UserId;
        var username = string.IsNullOrWhiteSpace(s.Username) ? userId : s.Username;
        var nombreCompleto = string.IsNullOrWhiteSpace(s.NombreCompleto) ? username : s.NombreCompleto;
        var rol = string.IsNullOrWhiteSpace(s.Rol) ? string.Empty : s.Rol;

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, userId),
            new Claim(ClaimTypes.Name,           username),
            new Claim(ClaimTypes.GivenName,      nombreCompleto),
            new Claim(ClaimTypes.Role,           rol),
        };
        return new AuthenticationState(
            new ClaimsPrincipal(new ClaimsIdentity(claims, "jwt")));
    }
}
