using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using VisitaPDV.Application.Common.Interfaces;
using VisitaPDV.Domain.Interfaces.Repositories;
using VisitaPDV.Infrastructure.Identity;
using VisitaPDV.Infrastructure.Persistence;
using VisitaPDV.Infrastructure.Repositories;
using VisitaPDV.Infrastructure.Services;

namespace VisitaPDV.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services, IConfiguration config)
    {
        // EF Core
        services.AddDbContext<ApplicationDbContext>(opts =>
            opts.UseSqlServer(
                config.GetConnectionString("DefaultConnection"),
                b => b.MigrationsAssembly(typeof(ApplicationDbContext).Assembly.FullName)));

        // Repositories genérico + específicos
        services.AddScoped(typeof(IRepository<>), typeof(BaseRepository<>));
        services.AddScoped<IUnitOfWork, UnitOfWork>();
        services.AddScoped<IUsuarioRepository, UsuarioRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IDispositivoRepository, DispositivoRepository>();
        services.AddScoped<IPdvRepository, PdvRepository>();
        services.AddScoped<IVisitaRepository, VisitaRepository>();
        services.AddScoped<INovedadRepository, NovedadRepository>();
        services.AddScoped<IDashboardRepository, DashboardRepository>();

        // Services
        services.AddHttpContextAccessor();
        services.AddScoped<ITokenService, TokenService>();
        services.AddScoped<IPasswordHasher, PasswordHasher>();
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<IAuditoriaService, AuditoriaService>();
        services.AddScoped<IAzureBlobService, AzureBlobService>();
        services.AddHttpClient<IGeminiService, GeminiService>(client =>
        {
            client.Timeout = System.TimeSpan.FromSeconds(15);
        });
        services.AddScoped<IAnonymizationService, AnonymizationService>();
        services.AddSingleton<IFirebaseNotificationService, FirebaseNotificationService>();
        services.AddScoped<IExportService, ExportService>();
        services.AddScoped<ICacheService, RedisCacheService>();

        // Redis
        var redisConn = config.GetConnectionString("Redis");
        if (!string.IsNullOrEmpty(redisConn))
            services.AddStackExchangeRedisCache(opts => opts.Configuration = redisConn);
        else
            services.AddDistributedMemoryCache(); // fallback sin Redis

        // JWT Authentication
        var jwtSettings = config.GetSection(JwtSettings.SectionName).Get<JwtSettings>()!;
        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(opts =>
            {
                opts.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidateAudience = true,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    ValidIssuer = jwtSettings.Issuer,
                    ValidAudience = jwtSettings.Audience,
                    IssuerSigningKey = new SymmetricSecurityKey(
                        Encoding.UTF8.GetBytes(jwtSettings.Secret)),
                    ClockSkew = TimeSpan.Zero,
                };
            });

        return services;
    }
}
