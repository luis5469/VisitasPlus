using Blazored.LocalStorage;
using Microsoft.AspNetCore.Components.Authorization;
using VisitaPDV.Admin.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddBlazoredLocalStorage();

// Solo servicios de auth para Blazor - sin esquema HTTP que cause redirects
builder.Services.AddAuthorizationCore();
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddScoped<AuthenticationStateProvider, AdminAuthStateProvider>();

// HttpClient apuntando a la API
// En desarrollo se acepta el certificado autofirmado del localhost
builder.Services.AddScoped(sp =>
{
    var apiBase = builder.Configuration["ApiBaseUrl"] ?? "https://localhost:7001";
    var handler = new HttpClientHandler();
    if (builder.Environment.IsDevelopment())
        handler.ServerCertificateCustomValidationCallback =
            HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
    return new HttpClient(handler)
    {
        BaseAddress = new Uri(apiBase),
        Timeout     = TimeSpan.FromSeconds(30)
    };
});

builder.Services.AddScoped<ApiClient>();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<VisitaPDV.Admin.Components.App>()
   .AddInteractiveServerRenderMode()
   .AllowAnonymous();

app.Run();
