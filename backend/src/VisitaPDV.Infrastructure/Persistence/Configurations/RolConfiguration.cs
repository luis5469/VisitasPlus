using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class RolConfiguration : IEntityTypeConfiguration<Rol>
{
    public void Configure(EntityTypeBuilder<Rol> builder)
    {
        builder.ToTable("Roles");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.Id).ValueGeneratedNever();
        builder.Property(r => r.Nombre).IsRequired().HasMaxLength(100);
        builder.Property(r => r.Descripcion).HasMaxLength(500);
        builder.HasIndex(r => r.Nombre).IsUnique();

        // Seed
        builder.HasData(
            new { Id = "ROL-VISITD", Nombre = "Visitador",     Descripcion = "Visitador de puntos de venta", Activo = true, CreatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc), UpdatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc) },
            new { Id = "ROL-SUPERV", Nombre = "Supervisor",    Descripcion = "Supervisor de zona",          Activo = true, CreatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc), UpdatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc) },
            new { Id = "ROL-ADMINS", Nombre = "Administrador", Descripcion = "Administrador del sistema",    Activo = true, CreatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc), UpdatedAt = new DateTime(2024,1,1,0,0,0,DateTimeKind.Utc) }
        );
    }
}
