using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VisitaPDV.Domain.Entities;

namespace VisitaPDV.Infrastructure.Persistence.Configurations;

public sealed class AuditoriaConfiguration : IEntityTypeConfiguration<Auditoria>
{
    public void Configure(EntityTypeBuilder<Auditoria> builder)
    {
        builder.ToTable("Auditorias");
        builder.HasKey(a => a.Id);
        builder.Property(a => a.Id).ValueGeneratedNever();
        builder.Property(a => a.Modulo).IsRequired().HasMaxLength(100);
        builder.Property(a => a.Accion).IsRequired().HasMaxLength(100);
        builder.Property(a => a.EntidadAfectada).HasMaxLength(100);
        builder.Property(a => a.EntidadId).HasMaxLength(100);
        builder.Property(a => a.DetalleAnterior).HasColumnType("nvarchar(max)");
        builder.Property(a => a.DetalleNuevo).HasColumnType("nvarchar(max)");
        builder.Property(a => a.IpAddress).HasMaxLength(45);
        builder.Property(a => a.UserAgent).HasMaxLength(500);
        builder.Property(a => a.MensajeError).HasMaxLength(2000);

        builder.HasIndex(a => a.UsuarioId);
        builder.HasIndex(a => a.CreatedAt);

        builder.HasOne(a => a.Usuario)
               .WithMany()
               .HasForeignKey(a => a.UsuarioId)
               .OnDelete(DeleteBehavior.SetNull);
    }
}
