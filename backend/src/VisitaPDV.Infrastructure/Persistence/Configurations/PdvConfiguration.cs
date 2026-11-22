using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class PdvConfiguration : IEntityTypeConfiguration<Pdv>
{
    public void Configure(EntityTypeBuilder<Pdv> builder)
    {
        builder.ToTable("PDV");
        builder.HasKey(p => p.Id);
        builder.Property(p => p.Id).ValueGeneratedNever();

        builder.Property(p => p.Codigo).IsRequired().HasMaxLength(20);
        builder.Property(p => p.Nombre).IsRequired().HasMaxLength(200);
        builder.Property(p => p.Direccion).IsRequired().HasMaxLength(300);
        builder.Property(p => p.Ciudad).IsRequired().HasMaxLength(100);
        builder.Property(p => p.Zona).HasMaxLength(100);
        builder.Property(p => p.Responsable).HasMaxLength(150);
        builder.Property(p => p.Telefono).HasMaxLength(20);
        builder.Property(p => p.Latitud).HasColumnType("decimal(10,7)").IsRequired();
        builder.Property(p => p.Longitud).HasColumnType("decimal(10,7)").IsRequired();
        builder.Property(p => p.GeofenceMetros).HasDefaultValue(100);
        builder.Property(p => p.Activo).HasDefaultValue(true);

        builder.HasIndex(p => p.Codigo).IsUnique();

        builder.HasMany(p => p.Visitas)
               .WithOne(v => v.Pdv)
               .HasForeignKey("PdvId")
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasMany(p => p.AgendaVisitas)
               .WithOne(a => a.Pdv)
               .HasForeignKey("PdvId")
               .OnDelete(DeleteBehavior.Restrict);
    }
}
