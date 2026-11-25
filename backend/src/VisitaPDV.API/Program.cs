using Serilog;
using VisitaPDV.API.Extensions;
using VisitaPDV.API.Middleware;
using VisitaPDV.Application;
using VisitaPDV.Infrastructure;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateBootstrapLogger();

try
{
    Log.Information("Iniciando VisitaPDV API...");

var builder = WebApplication.CreateBuilder(args);

    // Serilog
    builder.Host.UseSerilog((ctx, lc) => lc
        .ReadFrom.Configuration(ctx.Configuration)
        .Enrich.FromLogContext()
        .WriteTo.Console()
        .WriteTo.File("logs/visitapdv-.txt", rollingInterval: RollingInterval.Day));

    // Layers
    builder.Services.AddApplication();
    builder.Services.AddInfrastructure(builder.Configuration);

    // API
    builder.Services.AddControllers();
    builder.Services.AddSwaggerDocumentation();

    // Health checks
    builder.Services.AddHealthChecks();

    // CORS
    builder.Services.AddCors(opts =>
        opts.AddPolicy("AllowAll", policy =>
            policy.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader()));

    var app = builder.Build();

    // Serilog primero (fuera del exception handler) para leer el status code final
    app.UseSerilogRequestLogging();
    app.UseMiddleware<GlobalExceptionMiddleware>();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "VisitaPDV API v1"));
    }

    app.UseCors("AllowAll");
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();
    app.MapHealthChecks("/health");

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "VisitaPDV API terminó inesperadamente.");
}
finally
{
    Log.CloseAndFlush();
}
