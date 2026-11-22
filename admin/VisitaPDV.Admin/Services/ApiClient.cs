using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text;
using System.Text.Json;
using Blazored.LocalStorage;
using VisitaPDV.Admin.Models;

namespace VisitaPDV.Admin.Services;

public sealed class ApiClient(HttpClient http, ILocalStorageService storage)
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNamingPolicy        = JsonNamingPolicy.CamelCase,
        PropertyNameCaseInsensitive = true
    };

    // ── Auth ─────────────────────────────────────────────────────────────────
    public async Task<LoginAttemptResult> LoginAsync(string user, string password)
    {
        try
        {
            var resp = await http.PostAsJsonAsync("/api/auth/login",
                new LoginRequest(user, password, "admin-blazor"));

            if (!resp.IsSuccessStatusCode)
            {
                var apiError = await TryReadApiErrorAsync(resp);

                if (resp.StatusCode == System.Net.HttpStatusCode.Unauthorized)
                    return LoginAttemptResult.Fail(apiError ?? "Usuario o contraseña incorrectos.");

                if (resp.StatusCode == System.Net.HttpStatusCode.BadRequest)
                    return LoginAttemptResult.Fail(apiError ?? "La solicitud de inicio de sesión no es válida.");

                return LoginAttemptResult.Fail(apiError ?? "No se pudo completar el inicio de sesión. Intente nuevamente.");
            }

            var wrapper = await resp.Content.ReadFromJsonAsync<ApiResponse<LoginResponse>>(JsonOpts);
            if (wrapper?.Data is null)
                return LoginAttemptResult.Fail("La API devolvió una respuesta de autenticación vacía.");

            await storage.SetItemAsync("access_token", wrapper.Data.AccessToken);
            await storage.SetItemAsync("refresh_token", wrapper.Data.RefreshToken);
            await storage.SetItemAsync("login_response", wrapper.Data);
            return LoginAttemptResult.Ok(wrapper.Data);
        }
        catch (HttpRequestException)
        {
            return LoginAttemptResult.Fail($"No se pudo conectar con la API en {http.BaseAddress}. Verifique que el backend esté corriendo.");
        }
        catch (TaskCanceledException)
        {
            return LoginAttemptResult.Fail("La API tardó demasiado en responder. Intente nuevamente.");
        }
    }

    private async Task<string?> TryReadApiErrorAsync(HttpResponseMessage response)
    {
        try
        {
            var wrapper = await response.Content.ReadFromJsonAsync<ApiResponse<object>>(JsonOpts);
            if (wrapper is null)
                return null;

            if (!string.IsNullOrWhiteSpace(wrapper.Message) && !string.Equals(wrapper.Message, "OK", StringComparison.OrdinalIgnoreCase))
                return wrapper.Message;

            var errors = wrapper.Errors?.Where(static error => !string.IsNullOrWhiteSpace(error)).ToArray();
            return errors is { Length: > 0 } ? string.Join(" ", errors) : null;
        }
        catch (JsonException)
        {
            return null;
        }
    }

    public async Task LogoutAsync()
    {
        var token = await storage.GetItemAsync<string>("access_token");
        if (!string.IsNullOrEmpty(token))
        {
            http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token);
            try { await http.PostAsync("/api/auth/logout", null); } catch { }
        }

        await storage.RemoveItemAsync("access_token");
        await storage.RemoveItemAsync("refresh_token");
        await storage.RemoveItemAsync("login_response");
    }

    public async Task<LoginResponse?> GetSessionAsync()
        => await storage.GetItemAsync<LoginResponse>("login_response");

    // ── Request helper ────────────────────────────────────────────────────────
    private async Task SetAuthHeaderAsync()
    {
        var token = await storage.GetItemAsync<string>("access_token");
        http.DefaultRequestHeaders.Authorization = string.IsNullOrEmpty(token)
            ? null
            : new AuthenticationHeaderValue("Bearer", token);
    }

    private async Task<ApiRequestResult<T>> GetAsyncResult<T>(string url) where T : class
    {
        try
        {
            await SetAuthHeaderAsync();
            var resp = await http.GetAsync(url);
            if (!resp.IsSuccessStatusCode)
            {
                var apiError = await TryReadApiErrorAsync(resp);
                return ApiRequestResult<T>.Fail(apiError ?? $"La API respondió {(int)resp.StatusCode} al consultar {url}.");
            }

            var wrapper = await resp.Content.ReadFromJsonAsync<ApiResponse<T>>(JsonOpts);
            if (wrapper?.Data is null)
                return ApiRequestResult<T>.Fail($"La API devolvió una respuesta vacía para {url}.");

            return ApiRequestResult<T>.Ok(wrapper.Data);
        }
        catch (HttpRequestException)
        {
            return ApiRequestResult<T>.Fail($"No se pudo conectar con la API en {http.BaseAddress}.");
        }
        catch (TaskCanceledException)
        {
            return ApiRequestResult<T>.Fail("La API tardó demasiado en responder.");
        }
        catch (JsonException)
        {
            return ApiRequestResult<T>.Fail($"No se pudo interpretar la respuesta de {url}.");
        }
    }

    private async Task<T?> GetAsync<T>(string url) where T : class
        => (await GetAsyncResult<T>(url)).Data;

    private async Task<ApiRequestResult<bool>> SendAsyncResult(HttpMethod method, string url, object? body = null)
    {
        try
        {
            await SetAuthHeaderAsync();

            using var request = new HttpRequestMessage(method, url);
            if (body is not null)
            {
                var json = JsonSerializer.Serialize(body, JsonOpts);
                request.Content = new StringContent(json, Encoding.UTF8, "application/json");
            }

            var resp = await http.SendAsync(request);
            if (!resp.IsSuccessStatusCode)
            {
                var apiError = await TryReadApiErrorAsync(resp);
                return ApiRequestResult<bool>.Fail(apiError ?? $"La API respondió {(int)resp.StatusCode} al procesar {url}.");
            }

            return ApiRequestResult<bool>.Ok(true);
        }
        catch (HttpRequestException)
        {
            return ApiRequestResult<bool>.Fail($"No se pudo conectar con la API en {http.BaseAddress}.");
        }
        catch (TaskCanceledException)
        {
            return ApiRequestResult<bool>.Fail("La API tardó demasiado en responder.");
        }
    }

    private async Task<ApiRequestResult<T>> SendAsyncResult<T>(HttpMethod method, string url, object? body = null) where T : class
    {
        try
        {
            await SetAuthHeaderAsync();

            using var request = new HttpRequestMessage(method, url);
            if (body is not null)
            {
                var json = JsonSerializer.Serialize(body, JsonOpts);
                request.Content = new StringContent(json, Encoding.UTF8, "application/json");
            }

            var resp = await http.SendAsync(request);
            if (!resp.IsSuccessStatusCode)
            {
                var apiError = await TryReadApiErrorAsync(resp);
                return ApiRequestResult<T>.Fail(apiError ?? $"La API respondió {(int)resp.StatusCode} al procesar {url}.");
            }

            var wrapper = await resp.Content.ReadFromJsonAsync<ApiResponse<T>>(JsonOpts);
            if (wrapper?.Data is null)
                return ApiRequestResult<T>.Fail($"La API devolvió una respuesta vacía para {url}.");

            return ApiRequestResult<T>.Ok(wrapper.Data);
        }
        catch (HttpRequestException)
        {
            return ApiRequestResult<T>.Fail($"No se pudo conectar con la API en {http.BaseAddress}.");
        }
        catch (TaskCanceledException)
        {
            return ApiRequestResult<T>.Fail("La API tardó demasiado en responder.");
        }
        catch (JsonException)
        {
            return ApiRequestResult<T>.Fail($"No se pudo interpretar la respuesta de {url}.");
        }
    }

    // ── Dashboard ─────────────────────────────────────────────────────────────
    public Task<DashboardResumenModel?> GetDashboardAsync(DateTime? desde = null, DateTime? hasta = null)
    {
        var qs = BuildDateQs(desde, hasta);
        return GetAsync<DashboardResumenModel>($"/api/dashboard{qs}");
    }

    public Task<ApiRequestResult<DashboardResumenModel>> GetDashboardResultAsync(DateTime? desde = null, DateTime? hasta = null)
    {
        var qs = BuildDateQs(desde, hasta);
        return GetAsyncResult<DashboardResumenModel>($"/api/dashboard{qs}");
    }

    public async Task<byte[]?> ExportDashboardAsync(string formato, DateTime? desde, DateTime? hasta)
    {
        await SetAuthHeaderAsync();
        var qs = $"?formato={formato}{BuildDateQs(desde, hasta, append: true)}";
        var resp = await http.GetAsync($"/api/dashboard/exportar{qs}");
        return resp.IsSuccessStatusCode ? await resp.Content.ReadAsByteArrayAsync() : null;
    }

    // ── Usuarios ──────────────────────────────────────────────────────────────
    public Task<IEnumerable<UsuarioModel>?> GetUsuariosAsync()
        => GetAsync<IEnumerable<UsuarioModel>>("/api/admin/usuarios");

    public Task<ApiRequestResult<IEnumerable<UsuarioModel>>> GetUsuariosResultAsync()
        => GetAsyncResult<IEnumerable<UsuarioModel>>("/api/admin/usuarios");

    public async Task<bool> ToggleUsuarioActivoAsync(string id, bool activo)
    {
        var result = await SendAsyncResult(HttpMethod.Patch, $"/api/admin/usuarios/{id}/activo", new { activo });
        return result.Success;
    }

    public async Task<bool> ResetIntentosFallidosAsync(string id)
    {
        var result = await SendAsyncResult(HttpMethod.Post, $"/api/admin/usuarios/{id}/reset-intentos");
        return result.Success;
    }

    public Task<ApiRequestResult<bool>> CreateUsuarioAsync(CreateUsuarioModel model)
        => SendAsyncResult(HttpMethod.Post, "/api/admin/usuarios", model);

    public Task<ApiRequestResult<bool>> UpdateUsuarioAsync(string id, UpdateUsuarioModel model)
        => SendAsyncResult(HttpMethod.Put, $"/api/admin/usuarios/{id}", model);

    public Task<ApiRequestResult<bool>> CambiarPasswordAsync(string id, CambiarPasswordModel model)
        => SendAsyncResult(HttpMethod.Put, $"/api/admin/usuarios/{id}/password", model);

    // ── Farmacias ────────────────────────────────────────────────────────────
    public Task<ApiRequestResult<IEnumerable<FarmaciaModel>>> GetFarmaciasResultAsync()
        => GetAsyncResult<IEnumerable<FarmaciaModel>>("/api/admin/farmacias");

    public Task<ApiRequestResult<FarmaciaModel>> CreateFarmaciaAsync(UpsertFarmaciaModel model)
        => SendAsyncResult<FarmaciaModel>(HttpMethod.Post, "/api/admin/farmacias", model);

    public Task<ApiRequestResult<bool>> UpdateFarmaciaAsync(string id, UpsertFarmaciaModel model)
        => SendAsyncResult(HttpMethod.Put, $"/api/admin/farmacias/{id}", model);

    public Task<ApiRequestResult<bool>> ToggleFarmaciaActivoAsync(string id, bool activo)
        => SendAsyncResult(HttpMethod.Patch, $"/api/admin/farmacias/{id}/activo", new { activo });

    // ── Asignaciones ─────────────────────────────────────────────────────────
    public Task<ApiRequestResult<IEnumerable<AsignacionFarmaciaModel>>> GetAsignacionesResultAsync(DateTime? desde = null, DateTime? hasta = null)
        => GetAsyncResult<IEnumerable<AsignacionFarmaciaModel>>($"/api/admin/asignaciones{BuildDateQs(desde, hasta)}");

    public Task<ApiRequestResult<bool>> CreateAsignacionAsync(CreateAsignacionModel model)
        => SendAsyncResult(HttpMethod.Post, "/api/admin/asignaciones", model);

    public Task<ApiRequestResult<bool>> DeleteAsignacionAsync(string id)
        => SendAsyncResult(HttpMethod.Delete, $"/api/admin/asignaciones/{id}");

    // ── Roles ─────────────────────────────────────────────────────────────────
    public Task<IEnumerable<RolModel>?> GetRolesAsync()
        => GetAsync<IEnumerable<RolModel>>("/api/admin/roles");

    public Task<ApiRequestResult<IEnumerable<RolModel>>> GetRolesResultAsync()
        => GetAsyncResult<IEnumerable<RolModel>>("/api/admin/roles");

    // ── Permisos ──────────────────────────────────────────────────────────────
    public Task<IEnumerable<PermisoModel>?> GetPermisosAsync()
        => GetAsync<IEnumerable<PermisoModel>>("/api/admin/permisos");

    public Task<ApiRequestResult<IEnumerable<PermisoModel>>> GetPermisosResultAsync()
        => GetAsyncResult<IEnumerable<PermisoModel>>("/api/admin/permisos");

    // ── Auditoría ─────────────────────────────────────────────────────────────
    public Task<PagedResult<AuditoriaModel>?> GetAuditoriaAsync(int page = 1, int pageSize = 50)
        => GetAsync<PagedResult<AuditoriaModel>>($"/api/admin/auditoria?page={page}&pageSize={pageSize}");

    public Task<ApiRequestResult<PagedResult<AuditoriaModel>>> GetAuditoriaResultAsync(int page = 1, int pageSize = 50)
        => GetAsyncResult<PagedResult<AuditoriaModel>>($"/api/admin/auditoria?page={page}&pageSize={pageSize}");

    // ── Novedades ─────────────────────────────────────────────────────────────
    public Task<ApiRequestResult<NovedadesPagedResponse>> GetNovedadesResultAsync(
        string? estado = null,
        string? categoria = null,
        string? prioridad = null,
        string? pdvId = null,
        string? responsableId = null,
        DateTime? desde = null,
        DateTime? hasta = null,
        int pagina = 1,
        int tamano = 20)
    {
        var sb = new StringBuilder("/api/novedades?");
        if (!string.IsNullOrWhiteSpace(estado)) sb.Append($"estado={Uri.EscapeDataString(estado)}&");
        if (!string.IsNullOrWhiteSpace(categoria)) sb.Append($"categoria={Uri.EscapeDataString(categoria)}&");
        if (!string.IsNullOrWhiteSpace(prioridad)) sb.Append($"prioridad={Uri.EscapeDataString(prioridad)}&");
        if (!string.IsNullOrWhiteSpace(pdvId)) sb.Append($"pdvId={Uri.EscapeDataString(pdvId)}&");
        if (!string.IsNullOrWhiteSpace(responsableId)) sb.Append($"responsableId={Uri.EscapeDataString(responsableId)}&");
        if (desde.HasValue) sb.Append($"desde={desde.Value:yyyy-MM-dd}&");
        if (hasta.HasValue) sb.Append($"hasta={hasta.Value:yyyy-MM-dd}&");
        sb.Append($"pagina={pagina}&tamano={tamano}");

        return GetAsyncResult<NovedadesPagedResponse>(sb.ToString());
    }

    public Task<ApiRequestResult<NovedadModel>> GetNovedadResultAsync(string id)
        => GetAsyncResult<NovedadModel>($"/api/novedades/{id}");

    public Task<ApiRequestResult<NovedadModel>> UpdateNovedadAsync(string id, ActualizarNovedadModel model)
        => SendAsyncResult<NovedadModel>(HttpMethod.Put, $"/api/novedades/{id}", model);

    public Task<ApiRequestResult<NovedadModel>> CambiarEstadoNovedadAsync(string id, string nuevoEstado, string comentario)
        => SendAsyncResult<NovedadModel>(HttpMethod.Patch, $"/api/novedades/{id}/estado", new { nuevoEstado, comentario });

    public Task<ApiRequestResult<string>> GetSasUrlImagenAsync(string id, string imagenId)
        => GetAsyncResult<string>($"/api/novedades/{id}/imagenes/{imagenId}/sas");

    public Task<ApiRequestResult<NovedadAnalisisResult>> AnalizarNovedadConIAAsync(string descripcion)
        => SendAsyncResult<NovedadAnalisisResult>(HttpMethod.Post, "/api/novedades/analizar-ia", new { descripcion });

    // ── Helpers ───────────────────────────────────────────────────────────────
    private static string BuildDateQs(DateTime? desde, DateTime? hasta, bool append = false)
    {
        var parts = new List<string>();
        if (desde.HasValue) parts.Add($"desde={desde.Value:yyyy-MM-dd}");
        if (hasta.HasValue) parts.Add($"hasta={hasta.Value:yyyy-MM-dd}");
        if (parts.Count == 0) return string.Empty;
        var prefix = append ? "&" : "?";
        return prefix + string.Join("&", parts);
    }
}
