using Microsoft.EntityFrameworkCore;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence;

public sealed class ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
    : DbContext(options)
{
    // Auth
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Rol> Roles => Set<Rol>();
    public DbSet<Permiso> Permisos => Set<Permiso>();
    public DbSet<RolPermiso> RolPermisos => Set<RolPermiso>();
    public DbSet<UsuarioRol> UsuarioRoles => Set<UsuarioRol>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Dispositivo> Dispositivos => Set<Dispositivo>();
    public DbSet<Auditoria> Auditorias => Set<Auditoria>();

    // Negocio
    public DbSet<Pdv>             Pdvs          => Set<Pdv>();
    public DbSet<Visita>          Visitas        => Set<Visita>();
    public DbSet<AgendaVisita>    AgendaVisitas  => Set<AgendaVisita>();
    public DbSet<Novedad>         Novedades      => Set<Novedad>();
    public DbSet<NovedadHistorial> NovedadHistorial => Set<NovedadHistorial>();
    public DbSet<NovedadImagen>   NovedadImagenes => Set<NovedadImagen>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);

        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            foreach (var property in entityType.GetProperties())
            {
                if (property.ClrType == typeof(string))
                {
                    if (property.Name == "Id" || (property.Name.EndsWith("Id") && property.Name != "JwtId" && property.Name != "DeviceId"))
                    {
                        property.SetMaxLength(10);
                        property.SetColumnType("varchar(10)");
                    }
                }
            }
        }

        base.OnModelCreating(modelBuilder);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<VisitaPDV.Domain.Common.BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.SetCreatedAt(DateTime.UtcNow);
                    break;
                case EntityState.Modified:
                    entry.Entity.SetUpdatedAt(DateTime.UtcNow);
                    break;
            }
        }
        return base.SaveChangesAsync(cancellationToken);
    }
}
