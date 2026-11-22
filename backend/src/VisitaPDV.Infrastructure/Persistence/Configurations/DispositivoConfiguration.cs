using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class DispositivoConfiguration : IEntityTypeConfiguration<Dispositivo>
{
    public void Configure(EntityTypeBuilder<Dispositivo> builder)
    {
        builder.ToTable("Dispositivos");
        builder.HasKey(d => d.Id);
        builder.Property(d => d.Id).ValueGeneratedNever();
        builder.Property(d => d.DeviceId).IsRequired().HasMaxLength(255);
        builder.Property(d => d.Nombre).IsRequired().HasMaxLength(200);
        builder.Property(d => d.Plataforma).IsRequired().HasMaxLength(50);
        builder.Property(d => d.ModeloDispositivo).HasMaxLength(150);
        builder.Property(d => d.VersionSO).HasMaxLength(50);
        builder.Property(d => d.PushToken).HasMaxLength(512);

        builder.HasIndex(d => d.DeviceId).IsUnique();
        builder.HasIndex(d => d.UsuarioId);

        builder.HasOne(d => d.Usuario)
               .WithMany(u => u.Dispositivos)
               .HasForeignKey(d => d.UsuarioId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
