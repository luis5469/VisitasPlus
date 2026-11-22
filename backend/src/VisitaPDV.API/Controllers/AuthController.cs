using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Application.Common.Models;
using VisitaPDV.Application.Features.Auth.Commands;
using VisitaPDV.Application.Features.Auth.Dtos;
using VisitaPDV.Application.Features.Auth.Queries;

namespace VisitaPDV.API.Controllers;

public sealed class AuthController : BaseApiController
{
    // ------------------------------------------------------------------
    // POST /api/auth/login
    // ------------------------------------------------------------------
    /// <summary>Autenticar usuario y obtener tokens JWT + Refresh.</summary>
    [HttpPost("login")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var ua = Request.Headers.UserAgent.ToString();

        var command = new LoginCommand(
            request.UsernameOrEmail, request.Password,
            ip, ua,
            request.DeviceId, request.DeviceName, request.Plataforma);

        var result = await Mediator.Send(command);
        return Ok(ApiResponse<LoginResponse>.Ok(result));
    }

    // ------------------------------------------------------------------
    // POST /api/auth/refresh
    // ------------------------------------------------------------------
    /// <summary>Renovar access token usando refresh token.</summary>
    [HttpPost("refresh")]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Refresh([FromBody] RefreshTokenRequest request)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var ua = Request.Headers.UserAgent.ToString();

        var command = new RefreshTokenCommand(request.AccessToken, request.RefreshToken, ip, ua);
        var result = await Mediator.Send(command);
        return Ok(ApiResponse<LoginResponse>.Ok(result));
    }

    // ------------------------------------------------------------------
    // POST /api/auth/logout
    // ------------------------------------------------------------------
    /// <summary>Cerrar sesión revocando el refresh token activo.</summary>
    [HttpPost("logout")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Logout([FromBody] RevokeTokenRequest request)
    {
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var ua = Request.Headers.UserAgent.ToString();
        var currentUser = HttpContext.RequestServices.GetRequiredService<ICurrentUserService>();

        if (!currentUser.IsAuthenticated)
            return Unauthorized();

        var command = new LogoutCommand(
            request.RefreshToken, currentUser.UserId, ip, ua);

        await Mediator.Send(command);
        return Ok(ApiResponse.Ok("Sesión cerrada correctamente."));
    }

    // ------------------------------------------------------------------
    // GET /api/auth/me
    // ------------------------------------------------------------------
    /// <summary>Obtener información del usuario autenticado.</summary>
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<MeResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Me()
    {
        var currentUser = HttpContext.RequestServices.GetRequiredService<ICurrentUserService>();

        if (!currentUser.IsAuthenticated)
            return Unauthorized();

        var result = await Mediator.Send(new GetMeQuery(currentUser.UserId));
        return Ok(ApiResponse<MeResponse>.Ok(result));
    }

}
